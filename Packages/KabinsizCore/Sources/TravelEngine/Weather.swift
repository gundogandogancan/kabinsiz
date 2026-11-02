import Foundation

/// Where a day's weather came from (§42.2). The UI must always show this.
public enum WeatherEvidence: String, Codable, Sendable {
    case liveForecast = "LIVE_FORECAST"
    case cachedForecast = "CACHED_FORECAST"
    case seasonalGuidance = "SEASONAL_GUIDANCE"
    case userOverride = "USER_OVERRIDE"
    case noData = "NO_DATA"

    public var displayName: String {
        switch self {
        case .liveForecast: "Güncel tahmin"
        case .cachedForecast: "Son bilinen tahmin"
        case .seasonalGuidance: "Mevsimsel beklenti, hava tahmini değil"
        case .userOverride: "Senin girdiğin hava"
        case .noData: "Hava verisi yok"
        }
    }
}

public struct WeatherSnapshot: Codable, Hashable, Sendable {
    public let localDate: LocalDate
    public let evidence: WeatherEvidence
    public let provider: String?
    public let retrievedAt: Date?
    public let validUntil: Date?
    /// Optional on purpose: an unknown temperature is `nil`, never 0 °C (T-TRV-025).
    public let lowC: Double?
    public let highC: Double?
    public let precipitationProbability: Double?
    public let windKph: Double?
    public let isSynthetic: Bool

    public init(
        localDate: LocalDate, evidence: WeatherEvidence, provider: String? = nil, retrievedAt: Date? = nil,
        validUntil: Date? = nil, lowC: Double? = nil, highC: Double? = nil,
        precipitationProbability: Double? = nil, windKph: Double? = nil, isSynthetic: Bool = false
    ) {
        self.localDate = localDate
        self.evidence = evidence
        self.provider = provider
        self.retrievedAt = retrievedAt
        self.validUntil = validUntil
        self.lowC = lowC
        self.highC = highC
        self.precipitationProbability = precipitationProbability
        self.windKph = windKph
        self.isSynthetic = isSynthetic
    }

    public static func noData(_ date: LocalDate) -> WeatherSnapshot {
        WeatherSnapshot(localDate: date, evidence: .noData)
    }

    /// Forecast data past its validity is still shown, but as cached (T-TRV-018).
    public func aged(now: Date) -> WeatherSnapshot {
        guard evidence == .liveForecast, let validUntil, now > validUntil else { return self }
        return WeatherSnapshot(
            localDate: localDate, evidence: .cachedForecast, provider: provider, retrievedAt: retrievedAt,
            validUntil: validUntil, lowC: lowC, highC: highC, precipitationProbability: precipitationProbability,
            windKph: windKph, isSynthetic: isSynthetic
        )
    }

    /// "SYNTHETIC_FIXTURE · alındı 3 Kas 14:05" — provider and time when known (T-TRV-017).
    public var provenanceText: String? {
        guard evidence != .noData else { return nil }
        var parts = [provider ?? "Kaynak bilinmiyor"]
        if let retrievedAt { parts.append("alındı " + retrievedAt.formatted(date: .abbreviated, time: .shortened)) }
        return parts.joined(separator: " · ")
    }

    public var hasNumbers: Bool { lowC != nil || highC != nil }

    /// Cold enough that a warm outer layer should be planned. Unknown → `nil`, not "warm".
    public var needsWarmLayer: Bool? {
        guard let low = lowC ?? highC else { return nil }
        return low <= 15
    }

    public var rainLikely: Bool? {
        guard let p = precipitationProbability else { return nil }
        return p >= 0.5
    }

    /// Short chip text, e.g. "12–18 °C · %60 yağış". Never prints numbers it does not have.
    public var chipText: String {
        guard hasNumbers else { return evidence.displayName }
        var parts: [String] = []
        switch (lowC, highC) {
        case let (low?, high?): parts.append("\(Int(low.rounded()))–\(Int(high.rounded())) °C")
        case let (low?, nil): parts.append("en düşük \(Int(low.rounded())) °C")
        case let (nil, high?): parts.append("en yüksek \(Int(high.rounded())) °C")
        default: break
        }
        if let p = precipitationProbability { parts.append("%\(Int((p * 100).rounded())) yağış") }
        // Anything but a live forecast carries its label next to the numbers (T-TRV-018/020).
        switch evidence {
        case .liveForecast: break
        case .cachedForecast: parts.insert("Son bilinen tahmin", at: 0)
        case .seasonalGuidance: parts.insert("Mevsimsel beklenti, tahmin değil", at: 0)
        case .userOverride: parts.insert("Senin girdiğin", at: 0)
        case .noData: break
        }
        return parts.joined(separator: " · ")
    }
}

/// Weather source behind an interface so the planner never depends on a live API (ADR-004).
public protocol WeatherProvider: Sendable {
    var name: String { get }
    func snapshots(for destination: Destination, dates: [LocalDate]) async -> [WeatherSnapshot]
}

/// Default provider for every plan: every day is `NO_DATA`. Live weather only arrives through an explicit
/// user request in the app (egress register EG-001).
public struct NoDataWeatherProvider: WeatherProvider {
    public let name = "NONE"
    public init() {}
    public func snapshots(for destination: Destination, dates: [LocalDate]) async -> [WeatherSnapshot] {
        dates.map(WeatherSnapshot.noData)
    }
}

/// Deterministic synthetic weather for tests and the labelled demo trip.
public struct FixtureWeatherProvider: WeatherProvider {
    public let name = "SYNTHETIC_FIXTURE"
    private let byDate: [LocalDate: WeatherSnapshot]

    public init(_ snapshots: [WeatherSnapshot]) {
        byDate = Dictionary(snapshots.map { ($0.localDate, $0) }, uniquingKeysWith: { first, _ in first })
    }

    /// Dates without a fixture stay `NO_DATA`, mirroring a real forecast horizon (T-TRV-019).
    public func snapshots(for destination: Destination, dates: [LocalDate]) async -> [WeatherSnapshot] {
        dates.map { byDate[$0] ?? .noData($0) }
    }

    public static func day(_ date: LocalDate, low: Double, high: Double, rain: Double = 0, wind: Double = 10) -> WeatherSnapshot {
        WeatherSnapshot(
            localDate: date, evidence: .liveForecast, provider: "SYNTHETIC_FIXTURE",
            lowC: low, highC: high, precipitationProbability: rain, windKph: wind, isSynthetic: true
        )
    }
}
