import Foundation
import SystemContracts

// MARK: - Signals (§113: only what iOS really exposes)

/// Mirrors `ProcessInfo.ThermalState`. iOS gives a coarse level, never degrees; nothing here may be
/// shown or logged as a temperature.
public enum ThermalLevel: Int, Codable, CaseIterable, Comparable, Sendable {
    case nominal, fair, serious, critical
    public static func < (a: Self, b: Self) -> Bool { a.rawValue < b.rawValue }
}

/// `normal` until the OS warns. iOS has no "pressure is over" event, so a warning fades after a calm
/// period inside the governor.
public enum MemoryPressure: Int, Codable, CaseIterable, Comparable, Sendable {
    case normal, warning, critical
    public static func < (a: Self, b: Self) -> Bool { a.rawValue < b.rawValue }
}

/// Battery is read only when monitoring is enabled and needed. `UIDevice.batteryLevel` is -1 when
/// unknown; that stays `unavailable` and is never turned into a number (drill 5, V15-T-DEV-04).
public enum BatteryReading: Hashable, Sendable {
    case unavailable
    case level(percent: Int, charging: Bool)

    /// `deviceLevel` as UIKit reports it (0…1, or -1 when unknown). Anything outside 0…1 is unknown.
    public init(deviceLevel: Float, charging: Bool) {
        guard deviceLevel.isFinite, (0...1).contains(deviceLevel) else { self = .unavailable; return }
        self = .level(percent: Int((deviceLevel * 100).rounded()), charging: charging)
    }
}

public enum AppPresence: String, Codable, Sendable {
    case foreground
    /// Suspended or about to be; OS time limits apply.
    case background
    /// Protected data unavailable: vault keys and complete-protection files cannot be opened.
    case locked
}

/// One reading of everything the tier depends on. The iOS adapter fills it; tests inject it.
public struct DeviceSignals: Hashable, Sendable {
    public var thermal: ThermalLevel
    public var lowPowerMode: Bool
    public var memory: MemoryPressure
    public var battery: BatteryReading
    public var presence: AppPresence
    /// `false` only when the path monitor says unsatisfied; unknown counts as reachable, because egress
    /// is still gated per request by CitadelGate.
    public var networkReachable: Bool
    /// `volumeAvailableCapacityForImportantUsage`; nil when the OS did not answer.
    public var diskFreeBytes: Int64?
    /// The user is in a live camera flow right now (TURBO needs it, §113.1).
    public var activelyScanning: Bool

    public init(
        thermal: ThermalLevel = .nominal, lowPowerMode: Bool = false, memory: MemoryPressure = .normal,
        battery: BatteryReading = .unavailable, presence: AppPresence = .foreground, networkReachable: Bool = true,
        diskFreeBytes: Int64? = nil, activelyScanning: Bool = false
    ) {
        self.thermal = thermal
        self.lowPowerMode = lowPowerMode
        self.memory = memory
        self.battery = battery
        self.presence = presence
        self.networkReachable = networkReachable
        self.diskFreeBytes = diskFreeBytes
        self.activelyScanning = activelyScanning
    }
}

// MARK: - Policy

/// Health, ordered worst to best. Network and presence are separate axes and never wait for recovery.
public enum HealthLevel: Int, Codable, CaseIterable, Comparable, Sendable {
    case survival, conserve, balanced, turbo
    public static func < (a: Self, b: Self) -> Bool { a.rawValue < b.rawValue }

    var tier: ExecutionTier {
        switch self {
        case .survival: .survival
        case .conserve: .conserve
        case .balanced: .balanced
        case .turbo: .turbo
        }
    }
}

/// Why a tier was chosen. Codes only: no level, percentage or temperature travels with them.
public enum TierReason: String, Codable, CaseIterable, Sendable {
    case thermalFair = "THERMAL_FAIR", thermalSerious = "THERMAL_SERIOUS", thermalCritical = "THERMAL_CRITICAL"
    case lowPower = "LOW_POWER", memoryWarning = "MEMORY_WARNING", memoryCritical = "MEMORY_CRITICAL"
    case batteryCritical = "BATTERY_CRITICAL", batteryLow = "BATTERY_LOW", batteryUnknown = "BATTERY_UNKNOWN"
    case notScanning = "NOT_SCANNING", offline = "OFFLINE", background = "BACKGROUND", locked = "LOCKED"
    /// Signals are better again but the governor waits before stepping up (hysteresis).
    case recovering = "RECOVERING"
}

/// How often live camera analysis may run. Starting hypotheses (§113.1 "calibrate by test"), not
/// performance claims; WP15-18 replaces them with device measurements.
public enum CVCadence: Hashable, Sendable {
    case continuous(maxFramesPerSecond: Int)
    case paused
}

public struct TierDecision: Hashable, Sendable {
    public let tier: ExecutionTier
    public let health: HealthLevel
    public let budget: DeviceBudget
    public let reasons: [TierReason]

    public var cvCadence: CVCadence {
        switch tier {
        case .turbo: .continuous(maxFramesPerSecond: 15)
        case .balanced, .offline: .continuous(maxFramesPerSecond: 8)
        case .conserve: .continuous(maxFramesPerSecond: 2)
        case .survival, .lockedBackground: .paused
        }
    }

    /// One calm sentence for the screen, or nil when nothing changed for the user (§113.1 "warn subtly").
    /// Never a number: no degrees, no battery percentage, no frame rate.
    public var userNote: String? {
        switch tier {
        case .turbo, .balanced, .lockedBackground: return nil
        case .offline: return "Çevrimdışı. Dolabın ve vücut profilin bu cihazda çalışmaya devam ediyor."
        case .conserve:
            if reasons.contains(.thermalSerious) { return "Telefon ısındı. Görünüm sadeleşti; ölçü girme ve kaydetme açık." }
            if reasons.contains(.memoryWarning) { return "Bellek daraldı. Görünüm sadeleşti; ölçü girme ve kaydetme açık." }
            return "Pil azaldı. Görünüm sadeleşti; ölçü girme ve kaydetme açık."
        case .survival:
            if reasons.contains(.thermalCritical) { return "Telefon çok ısındı. Ağır işler durdu; ölçü girme ve kaydetme açık." }
            return "Bellek çok daraldı. Ağır işler durdu; ölçü girme ve kaydetme açık."
        }
    }
}

/// Deterministic signals → tier mapping (§113.1). Thresholds are hypotheses to calibrate on named
/// devices; what they protect is not: P0 (slider, save, delete) stays allowed in every foreground tier.
public enum TierPolicy {
    public static let batteryCriticalPercent = 10
    public static let batteryLowPercent = 20

    public static func health(for s: DeviceSignals) -> (HealthLevel, [TierReason]) {
        var reasons: [TierReason] = []
        var level = HealthLevel.turbo
        func cap(_ l: HealthLevel, _ r: TierReason) {
            reasons.append(r)
            level = min(level, l)
        }
        switch s.thermal {
        case .nominal: break
        case .fair: cap(.balanced, .thermalFair)
        case .serious: cap(.conserve, .thermalSerious)
        case .critical: cap(.survival, .thermalCritical)
        }
        switch s.memory {
        case .normal: break
        case .warning: cap(.conserve, .memoryWarning)
        case .critical: cap(.survival, .memoryCritical)
        }
        if s.lowPowerMode { cap(.balanced, .lowPower) }
        switch s.battery {
        // Unknown is not "full": no TURBO, and no invented number (drill 5).
        case .unavailable: cap(.balanced, .batteryUnknown)
        case .level(let p, let charging) where !charging && p <= batteryCriticalPercent: cap(.conserve, .batteryCritical)
        case .level(let p, let charging) where !charging && p <= batteryLowPercent: cap(.balanced, .batteryLow)
        case .level: break
        }
        if !s.activelyScanning { cap(.balanced, .notScanning) }
        return (level, reasons)
    }

    /// Combines an (already hysteresis-filtered) health level with presence and network.
    public static func decide(_ s: DeviceSignals, health: HealthLevel, reasons: [TierReason]) -> TierDecision {
        var reasons = reasons
        let tier: ExecutionTier
        switch s.presence {
        case .locked:
            reasons.append(.locked)
            tier = .lockedBackground
        case .background:
            reasons.append(.background)
            tier = .lockedBackground
        case .foreground:
            if !s.networkReachable { reasons.append(.offline) }
            tier = !s.networkReachable && health >= .balanced ? .offline : health.tier
        }
        var budget = DeviceBudget.defaults(for: tier)
        budget.allowsNetwork = budget.allowsNetwork && s.networkReachable
        return TierDecision(tier: tier, health: health, budget: budget, reasons: reasons)
    }
}

// MARK: - Compute placement (drill 7, V15-T-DEV-09)

public enum ComputeUnit: String, Codable, CaseIterable, Sendable {
    case neuralEngine = "NEURAL_ENGINE", gpu = "GPU", cpu = "CPU"
}

/// What a model may run on. `validatedUnits` are units with passing accuracy evidence: a fallback that
/// changes numerics is only "safe" once tested, so an unvalidated unit is never chosen.
public struct ModelComputeProfile: Hashable, Sendable {
    public let modelID: String
    public let preferred: [ComputeUnit]
    public let validatedUnits: Set<ComputeUnit>
    public let heavy: Bool

    public init(modelID: String, preferred: [ComputeUnit], validatedUnits: Set<ComputeUnit>, heavy: Bool) {
        self.modelID = modelID
        self.preferred = preferred
        self.validatedUnits = validatedUnits
        self.heavy = heavy
    }
}

public enum ComputePlan: Hashable, Sendable {
    case run(ComputeUnit, isFallback: Bool)
    /// The user enters the value by hand; the flow keeps working without the model.
    case manual(ManualReason)

    public enum ManualReason: String, Hashable, Sendable {
        case budgetForbidsHeavy = "BUDGET_FORBIDS_HEAVY"
        case noValidatedUnit = "NO_VALIDATED_UNIT"
    }
}

public enum ComputePlanner {
    public static func plan(_ model: ModelComputeProfile, available: Set<ComputeUnit>, budget: DeviceBudget) -> ComputePlan {
        if model.heavy, budget.maxConcurrentHeavyTasks == 0 { return .manual(.budgetForbidsHeavy) }
        for (index, unit) in model.preferred.enumerated() where available.contains(unit) && model.validatedUnits.contains(unit) {
            return .run(unit, isFallback: index > 0)
        }
        return .manual(.noValidatedUnit)
    }
}
