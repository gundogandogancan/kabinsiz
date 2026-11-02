import Foundation

/// A destination the user picked or typed. Weather is asked for the destination, never the
/// device location (§41.3).
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

    public struct Coordinate: Hashable, Sendable {
        public let latitude: Double
        public let longitude: Double
    }

    private struct Key: Hashable { let city: String; let country: String; let timeZoneID: String }

    /// City-centre points for the bundled cities only. Never stored on a trip: the weather request looks the
    /// destination up here at request time, so a saved or edited file can never make the app send another
    /// point (for example a GPS fix). Manual destinations have no entry and get no weather request.
    private static let centers: [Key: Coordinate] = [
        Key(city: "Barselona", country: "İspanya", timeZoneID: "Europe/Madrid"): .init(latitude: 41.3874, longitude: 2.1686),
        Key(city: "Barselona", country: "Venezuela", timeZoneID: "America/Caracas"): .init(latitude: 10.1333, longitude: -64.6833),
        Key(city: "Valensiya", country: "İspanya", timeZoneID: "Europe/Madrid"): .init(latitude: 39.4699, longitude: -0.3763),
        Key(city: "Valensiya", country: "Venezuela", timeZoneID: "America/Caracas"): .init(latitude: 10.162, longitude: -68.0077),
        Key(city: "Paris", country: "Fransa", timeZoneID: "Europe/Paris"): .init(latitude: 48.8566, longitude: 2.3522),
        Key(city: "Paris", country: "ABD (Teksas)", timeZoneID: "America/Chicago"): .init(latitude: 33.6609, longitude: -95.5555),
        Key(city: "Londra", country: "Birleşik Krallık", timeZoneID: "Europe/London"): .init(latitude: 51.5072, longitude: -0.1276),
        Key(city: "Londra", country: "Kanada (Ontario)", timeZoneID: "America/Toronto"): .init(latitude: 42.9849, longitude: -81.2453),
        Key(city: "İstanbul", country: "Türkiye", timeZoneID: "Europe/Istanbul"): .init(latitude: 41.0082, longitude: 28.9784),
        Key(city: "İzmir", country: "Türkiye", timeZoneID: "Europe/Istanbul"): .init(latitude: 38.4237, longitude: 27.1428),
        Key(city: "Antalya", country: "Türkiye", timeZoneID: "Europe/Istanbul"): .init(latitude: 36.8969, longitude: 30.7133),
        Key(city: "Oslo", country: "Norveç", timeZoneID: "Europe/Oslo"): .init(latitude: 59.9139, longitude: 10.7522),
        Key(city: "Roma", country: "İtalya", timeZoneID: "Europe/Rome"): .init(latitude: 41.9028, longitude: 12.4964),
        Key(city: "Berlin", country: "Almanya", timeZoneID: "Europe/Berlin"): .init(latitude: 52.52, longitude: 13.405),
        Key(city: "Amsterdam", country: "Hollanda", timeZoneID: "Europe/Amsterdam"): .init(latitude: 52.3676, longitude: 4.9041),
        Key(city: "New York", country: "ABD", timeZoneID: "America/New_York"): .init(latitude: 40.7128, longitude: -74.006),
        Key(city: "Tokyo", country: "Japonya", timeZoneID: "Asia/Tokyo"): .init(latitude: 35.6762, longitude: 139.6503),
        Key(city: "Sidney", country: "Avustralya", timeZoneID: "Australia/Sydney"): .init(latitude: -33.8688, longitude: 151.2093),
        Key(city: "Dubai", country: "BAE", timeZoneID: "Asia/Dubai"): .init(latitude: 25.2048, longitude: 55.2708),
    ]

    public static func cityCenter(for destination: Destination) -> Coordinate? {
        centers[Key(city: destination.city, country: destination.country, timeZoneID: destination.timeZoneID)]
    }

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
