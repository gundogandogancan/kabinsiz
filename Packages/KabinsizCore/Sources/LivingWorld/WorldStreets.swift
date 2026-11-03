import Foundation

/// One well-known street per city, for the street-photo backdrop (Apple Look Around). The list is
/// written by hand from general knowledge: names and a point on the street, nothing scraped, no
/// imagery stored. A point is only a request: when Apple has no Look Around scene there, the app falls
/// back to the owned 3D street or the studio and says so. Coordinates are approximate (UNVERIFIED
/// until a scene loads for them).
public struct FamousStreet: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let city: String
    /// ISO 3166-1 alpha-2.
    public let country: String
    public let street: String
    public let latitude: Double
    public let longitude: Double
    public let timeZoneID: String
    /// The owned 3D street for this city, when one ships (used when Look Around is unavailable).
    public let ownedScene: SceneCity?

    public init(id: String, city: String, country: String, street: String, latitude: Double, longitude: Double,
                timeZoneID: String, ownedScene: SceneCity? = nil) {
        self.id = id
        self.city = city
        self.country = country
        self.street = street
        self.latitude = latitude
        self.longitude = longitude
        self.timeZoneID = timeZoneID
        self.ownedScene = ownedScene
    }

    public var timeZone: TimeZone? { TimeZone(identifier: timeZoneID) }
}

public enum FamousStreetCatalog {
    /// How far from a city's street a located person may be and still get that city.
    public static let matchRadiusKm = 60.0

    public static let all: [FamousStreet] = [
        s("TR-IST", "İstanbul", "TR", "İstiklal Caddesi", 41.0335, 28.9773, "Europe/Istanbul", .istanbul),
        s("TR-ANK", "Ankara", "TR", "Tunalı Hilmi Caddesi", 39.9049, 32.8605, "Europe/Istanbul"),
        s("TR-IZM", "İzmir", "TR", "Kıbrıs Şehitleri Caddesi", 38.4362, 27.1428, "Europe/Istanbul"),
        s("ES-BCN", "Barcelona", "ES", "Passeig de Gràcia", 41.3925, 2.1650, "Europe/Madrid", .barcelona),
        s("ES-MAD", "Madrid", "ES", "Gran Vía", 40.4203, -3.7058, "Europe/Madrid"),
        s("FR-PAR", "Paris", "FR", "Avenue des Champs-Élysées", 48.8697, 2.3078, "Europe/Paris"),
        s("GB-LON", "Londra", "GB", "Oxford Street", 51.5154, -0.1410, "Europe/London"),
        s("DE-BER", "Berlin", "DE", "Kurfürstendamm", 52.5030, 13.3290, "Europe/Berlin"),
        s("DE-MUC", "Münih", "DE", "Kaufingerstraße", 48.1376, 11.5720, "Europe/Berlin"),
        s("IT-ROM", "Roma", "IT", "Via del Corso", 41.9010, 12.4810, "Europe/Rome"),
        s("IT-MIL", "Milano", "IT", "Via Monte Napoleone", 45.4683, 9.1960, "Europe/Rome"),
        s("AT-VIE", "Viyana", "AT", "Kärntner Straße", 48.2058, 16.3710, "Europe/Vienna"),
        s("NL-AMS", "Amsterdam", "NL", "Kalverstraat", 52.3700, 4.8910, "Europe/Amsterdam"),
        s("CZ-PRG", "Prag", "CZ", "Václavské náměstí", 50.0815, 14.4270, "Europe/Prague"),
        s("PT-LIS", "Lizbon", "PT", "Avenida da Liberdade", 38.7190, -9.1450, "Europe/Lisbon"),
        s("GR-ATH", "Atina", "GR", "Ermou", 37.9765, 23.7290, "Europe/Athens"),
        s("CH-ZRH", "Zürih", "CH", "Bahnhofstrasse", 47.3720, 8.5390, "Europe/Zurich"),
        s("DK-CPH", "Kopenhag", "DK", "Strøget", 55.6780, 12.5750, "Europe/Copenhagen"),
        s("SE-STO", "Stockholm", "SE", "Drottninggatan", 59.3340, 18.0620, "Europe/Stockholm"),
        s("AE-DXB", "Dubai", "AE", "Sheikh Mohammed bin Rashid Boulevard", 25.1950, 55.2760, "Asia/Dubai"),
        s("US-NYC", "New York", "US", "Fifth Avenue", 40.7590, -73.9775, "America/New_York"),
        s("US-LAX", "Los Angeles", "US", "Rodeo Drive", 34.0690, -118.4040, "America/Los_Angeles"),
        s("US-SFO", "San Francisco", "US", "Market Street", 37.7880, -122.4040, "America/Los_Angeles"),
        s("US-CHI", "Chicago", "US", "Michigan Avenue", 41.8950, -87.6240, "America/Chicago"),
        s("CA-TOR", "Toronto", "CA", "Yonge Street", 43.6560, -79.3810, "America/Toronto"),
        s("MX-MEX", "Meksiko", "MX", "Paseo de la Reforma", 19.4270, -99.1680, "America/Mexico_City"),
        s("BR-SAO", "São Paulo", "BR", "Avenida Paulista", -23.5640, -46.6530, "America/Sao_Paulo"),
        s("AR-BUE", "Buenos Aires", "AR", "Avenida 9 de Julio", -34.6037, -58.3816, "America/Argentina/Buenos_Aires"),
        s("JP-TYO", "Tokyo", "JP", "Omotesandō", 35.6655, 139.7120, "Asia/Tokyo"),
        s("JP-OSA", "Osaka", "JP", "Midōsuji", 34.6900, 135.5010, "Asia/Tokyo"),
        s("KR-SEL", "Seul", "KR", "Myeongdong-gil", 37.5636, 126.9850, "Asia/Seoul"),
        s("SG-SIN", "Singapur", "SG", "Orchard Road", 1.3040, 103.8320, "Asia/Singapore"),
        s("HK-HKG", "Hong Kong", "HK", "Nathan Road", 22.3020, 114.1720, "Asia/Hong_Kong"),
        s("AU-SYD", "Sidney", "AU", "George Street", -33.8700, 151.2070, "Australia/Sydney"),
        s("AU-MEL", "Melbourne", "AU", "Collins Street", -37.8150, 144.9650, "Australia/Melbourne"),
        s("ZA-CPT", "Cape Town", "ZA", "Long Street", -33.9230, 18.4170, "Africa/Johannesburg"),
    ]

    private static func s(_ id: String, _ city: String, _ country: String, _ street: String, _ lat: Double, _ lon: Double,
                          _ tz: String, _ owned: SceneCity? = nil) -> FamousStreet {
        FamousStreet(id: id, city: city, country: country, street: street, latitude: lat, longitude: lon, timeZoneID: tz, ownedScene: owned)
    }

    public static func street(id: String) -> FamousStreet? { all.first { $0.id == id } }

    /// The catalogue city nearest to a position, if one is within `matchRadiusKm`. The position is
    /// used here and dropped; only the returned street's id is ever kept.
    public static func nearest(latitude: Double, longitude: Double, within km: Double = matchRadiusKm) -> FamousStreet? {
        let best = all.map { ($0, distanceKm(latitude, longitude, $0.latitude, $0.longitude)) }.min { $0.1 < $1.1 }
        guard let best, best.1 <= km else { return nil }
        return best.0
    }

    /// Great-circle distance (haversine, mean Earth radius).
    public static func distanceKm(_ lat1: Double, _ lon1: Double, _ lat2: Double, _ lon2: Double) -> Double {
        let r = 6_371.0
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) * sin(dLon / 2) * sin(dLon / 2)
        return 2 * r * atan2(sqrt(a), sqrt(1 - a))
    }
}
