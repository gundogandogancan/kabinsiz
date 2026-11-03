import Foundation

/// The body controls of the first proof (§133.1, §108). Ranges exist only to keep the shape drawable;
/// they are not norms, ideals or plausibility judgements about people (§123 Journey A.2).
public enum BodyParameter: String, Codable, CaseIterable, Sendable {
    case height = "HEIGHT"
    case shoulderWidth = "SHOULDER_WIDTH"
    case chest = "CHEST"
    case waist = "WAIST"
    case hip = "HIP"

    public var displayName: String {
        switch self {
        case .height: "Boy"
        case .shoulderWidth: "Omuz genişliği"
        case .chest: "Göğüs çevresi"
        case .waist: "Bel çevresi"
        case .hip: "Kalça çevresi"
        }
    }

    /// Mesh-safety range in centimetres.
    public var safeRange: ClosedRange<Double> {
        switch self {
        case .height: 120...220
        case .shoulderWidth: 30...60
        case .chest: 60...160
        case .waist: 50...160
        case .hip: 60...170
        }
    }

    /// Where a new neutral body starts. A drawing starting point, not a measurement or a target.
    public var neutralStartCm: Double {
        switch self {
        case .height: 170
        case .shoulderWidth: 42
        case .chest: 95
        case .waist: 82
        case .hip: 98
        }
    }

    public static let sliderStepCm = 0.5
}

public enum LengthUnit: String, Codable, CaseIterable, Sendable {
    case centimeters = "CM"
    case inches = "IN"

    public var symbol: String { self == .centimeters ? "cm" : "inç" }
    public var spokenName: String { self == .centimeters ? "santimetre" : "inç" }
}

/// A length stored once, in tenths of a millimetre, so unit changes never re-convert a stored value
/// (V15-T-BOD-04): 1 in = 254 tenths of a millimetre exactly.
public struct BodyLength: Codable, Hashable, Comparable, Sendable {
    public let tenthsOfMillimeter: Int

    public init(tenthsOfMillimeter: Int) { self.tenthsOfMillimeter = tenthsOfMillimeter }

    /// Non-finite or absurd input (NaN, ∞, a pasted 1e300) becomes -1, which no safe range accepts,
    /// instead of trapping on the integer conversion.
    public init(_ value: Double, _ unit: LengthUnit) {
        let tenths = (unit == .centimeters ? value * 100 : value * 254).rounded()
        tenthsOfMillimeter = tenths.isFinite && abs(tenths) < 1e9 ? Int(tenths) : -1
    }

    public var centimeters: Double { Double(tenthsOfMillimeter) / 100 }

    public func value(in unit: LengthUnit) -> Double {
        unit == .centimeters ? Double(tenthsOfMillimeter) / 100 : Double(tenthsOfMillimeter) / 254
    }

    /// One decimal, Turkish comma, e.g. "81,5 cm".
    public func formatted(_ unit: LengthUnit) -> String {
        let v = value(in: unit)
        let text = v.formatted(.number.precision(.fractionLength(0...1)).locale(Locale(identifier: "tr_TR")))
        return "\(text) \(unit.symbol)"
    }

    public static func < (a: Self, b: Self) -> Bool { a.tenthsOfMillimeter < b.tenthsOfMillimeter }
}

/// Where a value came from. Only `userMeasured` may feed size advice (§123 A.5: "exact value only if
/// manually entered"); slider shapes are for the picture.
public enum ValueSource: String, Codable, Sendable {
    case neutralStart = "NEUTRAL_START"
    case sliderShaped = "SLIDER_SHAPED"
    case userMeasured = "USER_MEASURED"

    public var label: String {
        switch self {
        case .neutralStart: "Başlangıç (ölçü değil)"
        case .sliderShaped: "Kaydırıcıyla şekillendirildi (ölçü değil)"
        case .userMeasured: "Senin girdiğin ölçü"
        }
    }
}

public struct BodyValue: Codable, Hashable, Sendable {
    public let length: BodyLength
    public let source: ValueSource

    public init(_ length: BodyLength, source: ValueSource) {
        self.length = length
        self.source = source
    }
}

/// One user change: a slider drag or a typed measurement.
public struct BodyEdit: Codable, Hashable, Sendable {
    public let parameter: BodyParameter
    public let length: BodyLength
    public let source: ValueSource

    public init(_ parameter: BodyParameter, _ length: BodyLength, source: ValueSource) {
        self.parameter = parameter
        self.length = length
        self.source = source
    }

    public static func slider(_ parameter: BodyParameter, cm: Double) -> BodyEdit {
        BodyEdit(parameter, BodyLength(cm, .centimeters), source: .sliderShaped)
    }

    public static func measured(_ parameter: BodyParameter, _ value: Double, _ unit: LengthUnit) -> BodyEdit {
        BodyEdit(parameter, BodyLength(value, unit), source: .userMeasured)
    }
}

public enum BodyEditError: Error, Equatable, Sendable {
    case outOfSafeRange(BodyParameter)
    case unsafeGeometry(String)
    case neutralIsNotAMeasurement
}

/// The canonical body truth (§102.3: one owner). Immutable value; every accepted change is a new revision.
public struct BodyProfile: Codable, Hashable, Sendable {
    public static let schemaVersion = 1

    public private(set) var revision: Int
    public private(set) var values: [BodyParameter: BodyValue]
    public var preferredUnit: LengthUnit

    /// A new neutral body at revision 1. Every value is marked as a starting point, not a measurement.
    public static func neutral(unit: LengthUnit = .centimeters) -> BodyProfile {
        var values: [BodyParameter: BodyValue] = [:]
        for p in BodyParameter.allCases { values[p] = BodyValue(BodyLength(p.neutralStartCm, .centimeters), source: .neutralStart) }
        return BodyProfile(revision: 1, values: values, preferredUnit: unit)
    }

    public init(revision: Int, values: [BodyParameter: BodyValue], preferredUnit: LengthUnit) {
        self.revision = revision
        self.values = values
        self.preferredUnit = preferredUnit
    }

    public subscript(_ p: BodyParameter) -> BodyValue {
        values[p] ?? BodyValue(BodyLength(p.neutralStartCm, .centimeters), source: .neutralStart)
    }

    /// Widest shoulder allowed per cm of height. Without it a 120 cm body with 60 cm shoulders folds the
    /// outline at the neck (found by V15-T-BOD-02). Real bodies sit far below it (≈0.23–0.27).
    public static let maxShoulderToHeight = 0.45

    /// The range a slider may offer for `p` given the other values: the fixed safe range, narrowed by the
    /// shoulder/height link. The UI uses it so a drag can never reach an unsafe shape.
    public func allowedRange(_ p: BodyParameter) -> ClosedRange<Double> {
        let base = p.safeRange
        // Linked bounds snap inward to the slider step, so every offered stop survives storage rounding.
        let step = BodyParameter.sliderStepCm
        switch p {
        case .shoulderWidth:
            let upper = (self[.height].length.centimeters * Self.maxShoulderToHeight / step).rounded(.down) * step
            return base.lowerBound...max(base.lowerBound, min(base.upperBound, upper))
        case .height:
            let lower = (self[.shoulderWidth].length.centimeters / Self.maxShoulderToHeight / step).rounded(.up) * step
            return min(base.upperBound, max(base.lowerBound, lower))...base.upperBound
        default:
            return base
        }
    }

    /// Range check, then a geometry check on the resulting shape. On failure nothing changes.
    public func applying(_ edit: BodyEdit) throws(BodyEditError) -> BodyProfile {
        guard edit.source != .neutralStart else { throw .neutralIsNotAMeasurement }
        guard allowedRange(edit.parameter).contains(edit.length.centimeters) else { throw .outOfSafeRange(edit.parameter) }
        var next = self
        next.values[edit.parameter] = BodyValue(edit.length, source: edit.source)
        next.revision = revision + 1
        _ = try Silhouette.make(for: next)
        return next
    }

    /// Every parameter present and inside its safe range, and a drawable shape. Used for anything that
    /// did not come through `applying`: a stored record, an undo target.
    public func validate() throws(BodyEditError) {
        for p in BodyParameter.allCases {
            guard let v = values[p] else { throw .unsafeGeometry("missing \(p.rawValue)") }
            guard p.safeRange.contains(v.length.centimeters) else { throw .outOfSafeRange(p) }
        }
        guard allowedRange(.shoulderWidth).contains(self[.shoulderWidth].length.centimeters) else { throw .outOfSafeRange(.shoulderWidth) }
        guard revision > 0, values.count == BodyParameter.allCases.count else { throw .unsafeGeometry("shape") }
        _ = try Silhouette.make(for: self)
    }

    /// Same values as `other`, at the next revision. Used by undo/redo: revisions only ever go up, so
    /// stale-write guards keep working (V15-T-ORC-08), while the parameters match exactly (V15-T-BOD-03).
    public func restoring(_ other: BodyProfile) -> BodyProfile {
        BodyProfile(revision: revision + 1, values: other.values, preferredUnit: preferredUnit)
    }

    /// Only typed measurements, for size advice. Slider shapes and starting values never appear here.
    public var measuredCentimeters: [BodyParameter: Double] {
        values.reduce(into: [:]) { out, pair in
            if pair.value.source == .userMeasured { out[pair.key] = pair.value.length.centimeters }
        }
    }

    public func sameShape(as other: BodyProfile) -> Bool { values == other.values }
}

/// Undo/redo for one editing session. Keeps profiles, not diffs, so a restore is exact.
public struct BodyEditHistory: Sendable {
    public static let limit = 50
    private var past: [BodyProfile] = []
    private var future: [BodyProfile] = []

    public init() {}

    public var canUndo: Bool { !past.isEmpty }
    public var canRedo: Bool { !future.isEmpty }

    public mutating func recordCommit(previous: BodyProfile) {
        past.append(previous)
        if past.count > Self.limit { past.removeFirst(past.count - Self.limit) }
        future.removeAll()
    }

    /// The profile to restore, and the current one goes on the redo stack.
    public mutating func undo(from current: BodyProfile) -> BodyProfile? {
        guard let target = past.popLast() else { return nil }
        future.append(current)
        return current.restoring(target)
    }

    public mutating func redo(from current: BodyProfile) -> BodyProfile? {
        guard let target = future.popLast() else { return nil }
        past.append(current)
        return current.restoring(target)
    }

    public mutating func reset() {
        past.removeAll()
        future.removeAll()
    }
}
