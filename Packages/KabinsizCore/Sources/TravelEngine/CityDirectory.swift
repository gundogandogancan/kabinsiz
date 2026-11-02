import Foundation

/// A destination the user picked or typed. Coordinates are deliberately absent in P0:
/// weather needs a destination, never the device location (§41.3).
public struct Destination: Codable, Hashable, Sendable {
    public let city: String
    public let country: String
    public let timeZoneID: String
    /// `false` when typed manually and the time zone is only a guess (§49.2 `TIMEZONE_UNVERIFIED`).
    public let timeZoneVerified: Bool

    public init(city: String, country: String, timeZoneID: String, timeZoneVerified: Bool) {
        self.city = city
        self.country = country
        self.timeZoneID = timeZoneID
        self.timeZoneVerified = timeZoneVerified
    }

    public var timeZone: TimeZone { TimeZone(identifier: timeZoneID) ?? .current }
    public var displayName: String { "\(city), \(country)" }
}

/// Small bundled lookup so city search works offline with no geocoder. It is not a gazetteer:
/// anything missing goes through manual entry.
public enum CityDirectory {
    public static let entries: [Destination] = [
        .init(city: "Barselona", country: "İspanya", timeZoneID: "Europe/Madrid", timeZoneVerified: true),
        .init(city: "Barselona", country: "Venezuela", timeZoneID: "America/Caracas", timeZoneVerified: true),
        .init(city: "Valensiya", country: "İspanya", timeZoneID: "Europe/Madrid", timeZoneVerified: true),
        .init(city: "Valensiya", country: "Venezuela", timeZoneID: "America/Caracas", timeZoneVerified: true),
        .init(city: "Paris", country: "Fransa", timeZoneID: "Europe/Paris", timeZoneVerified: true),
        .init(city: "Paris", country: "ABD (Teksas)", timeZoneID: "America/Chicago", timeZoneVerified: true),
        .init(city: "Londra", country: "Birleşik Krallık", timeZoneID: "Europe/London", timeZoneVerified: true),
        .init(city: "Londra", country: "Kanada (Ontario)", timeZoneID: "America/Toronto", timeZoneVerified: true),
        .init(city: "İstanbul", country: "Türkiye", timeZoneID: "Europe/Istanbul", timeZoneVerified: true),
        .init(city: "İzmir", country: "Türkiye", timeZoneID: "Europe/Istanbul", timeZoneVerified: true),
        .init(city: "Antalya", country: "Türkiye", timeZoneID: "Europe/Istanbul", timeZoneVerified: true),
        .init(city: "Oslo", country: "Norveç", timeZoneID: "Europe/Oslo", timeZoneVerified: true),
        .init(city: "Roma", country: "İtalya", timeZoneID: "Europe/Rome", timeZoneVerified: true),
        .init(city: "Berlin", country: "Almanya", timeZoneID: "Europe/Berlin", timeZoneVerified: true),
        .init(city: "Amsterdam", country: "Hollanda", timeZoneID: "Europe/Amsterdam", timeZoneVerified: true),
        .init(city: "New York", country: "ABD", timeZoneID: "America/New_York", timeZoneVerified: true),
        .init(city: "Tokyo", country: "Japonya", timeZoneID: "Asia/Tokyo", timeZoneVerified: true),
        .init(city: "Sidney", country: "Avustralya", timeZoneID: "Australia/Sydney", timeZoneVerified: true),
        .init(city: "Dubai", country: "BAE", timeZoneID: "Asia/Dubai", timeZoneVerified: true),
    ]

    /// Case- and diacritic-insensitive prefix match. Several results means the UI must ask (T-TRV-003).
    public static func search(_ query: String) -> [Destination] {
        let needle = normalize(query)
        guard !needle.isEmpty else { return [] }
        return entries.filter { normalize($0.city).hasPrefix(needle) }
    }

    /// Manual fallback: keeps the user's text and marks the zone unverified.
    public static func manual(city: String, country: String, deviceTimeZone: TimeZone = .current) -> Destination {
        Destination(
            city: city.trimmingCharacters(in: .whitespacesAndNewlines),
            country: country.trimmingCharacters(in: .whitespacesAndNewlines),
            timeZoneID: deviceTimeZone.identifier,
            timeZoneVerified: false
        )
    }

    static func normalize(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "tr_TR"))
            .replacingOccurrences(of: "ı", with: "i")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
