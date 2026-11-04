import Foundation

// v3.5 WP35-01: city identity and the three scene tiers. The home world is drawn where the user is
// (or chose), never a default city pretending to be theirs. Nothing here reads location: the app passes
// a city it got from the user's choice, the bundled catalogue, or Apple's reverse geocoder (disclosed).

/// Where a city name came from. Shown in the scene's truth line.
public enum CityIdentitySource: String, Codable, Hashable, Sendable {
    /// Picked by the user from the list.
    case userChosen = "USER_CHOSEN"
    /// The bundled street catalogue matched the device position (within `FamousStreetCatalog.matchRadiusKm`).
    case catalogue = "CATALOGUE"
    /// Apple's reverse geocoder named the city (a network request to Apple, disclosed in the location prompt).
    case reverseGeocoded = "REVERSE_GEOCODED"
}

/// A city the user is in or chose. Only the name, country and time zone are kept; never the position.
public struct CityIdentity: Codable, Hashable, Sendable {
    public let name: String
    /// ISO 3166-1 alpha-2, upper case. Empty when unknown.
    public let countryCode: String
    public let timeZoneID: String?
    public let source: CityIdentitySource

    public init(name: String, countryCode: String, timeZoneID: String?, source: CityIdentitySource) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.countryCode = countryCode.uppercased()
        self.timeZoneID = timeZoneID
        self.source = source
    }

    public init(street: FamousStreet, source: CityIdentitySource) {
        self.init(name: street.city, countryCode: street.country, timeZoneID: street.timeZoneID, source: source)
    }

    /// Diacritic- and case-insensitive key, with the common exonyms folded ("Barselona" = "Barcelona").
    public var matchKey: String { Self.fold(name) }

    static func fold(_ s: String) -> String {
        let base = s.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .replacingOccurrences(of: "ı", with: "i")
            .lowercased()
            .filter { $0.isLetter }
        return exonyms[base] ?? base
    }

    /// Turkish ↔ local names of the catalogue cities, so a geocoder answer in either language matches.
    private static let exonyms: [String: String] = [
        "barselona": "barcelona", "londra": "london", "munih": "munchen", "munich": "munchen", "viyana": "wien",
        "vienna": "wien", "prag": "praha", "prague": "praha", "lizbon": "lisboa", "lisbon": "lisboa",
        "atina": "athina", "athens": "athina", "zurih": "zurich", "kopenhag": "kobenhavn", "copenhagen": "kobenhavn",
        "seul": "seoul", "singapur": "singapore", "sidney": "sydney", "meksiko": "ciudaddemexico", "mexicocity": "ciudaddemexico",
        "roma": "rome", "milano": "milan", "istanbul": "istanbul", "izmir": "izmir",
    ]
}

/// The three ways a city is drawn (v3.5 §3).
public enum CitySceneTier: String, Codable, Hashable, Sendable, CaseIterable {
    /// A: a curated street built by this project (owned 3D street, Blender light).
    case curated = "A_CURATED"
    /// B: a street generated from open map data (OSM2World, ODbL attribution). Ships per city once built.
    case procedural = "B_PROCEDURAL"
    /// C: the neutral atelier, labelled with the real city name; never another city's street.
    case atelier = "C_ATELIER"
}

/// What the home draws for a city, and the one line that says so.
public struct CitySceneDecision: Hashable, Sendable {
    public let tier: CitySceneTier
    /// The owned scene for tier A; `.studio` for C.
    public let scene: SceneCity
    /// The city name the chip shows. Always the real one, also on the atelier.
    public let placeName: String
    /// Why this tier, in plain Turkish.
    public let reason: String
    /// Attribution that must be on screen (ODbL for tier B), or nil.
    public let attribution: String?
}

public enum CitySceneResolver {
    /// Cities with a built tier-B street in this bundle, by `CityIdentity.matchKey` + country.
    /// None ship yet: the OSM2World pipeline is CODED in tools/, its output is not bundled.
    public static let bundledProcedural: Set<String> = []

    /// Decide the tier. A city only gets a curated street when both the name and the country match
    /// (Barcelona, Venezuela never gets the Eixample street); otherwise B when built, else C.
    public static func resolve(_ identity: CityIdentity?, procedural: Set<String> = bundledProcedural) -> CitySceneDecision {
        guard let identity, !identity.name.isEmpty else {
            return CitySceneDecision(tier: .atelier, scene: .studio, placeName: "Stüdyo",
                                     reason: "Şehir seçilmedi · nötr atölye", attribution: nil)
        }
        if let owned = curated(for: identity) {
            return CitySceneDecision(tier: .curated, scene: owned, placeName: identity.name,
                                     reason: "Kabinsiz'in çizdiği \(owned.displayName) sokağı", attribution: nil)
        }
        if procedural.contains(proceduralKey(identity)) {
            return CitySceneDecision(tier: .procedural, scene: .studio, placeName: identity.name,
                                     reason: "Açık harita verisinden üretilmiş sokak",
                                     attribution: "© OpenStreetMap katkıda bulunanlar (ODbL)")
        }
        return CitySceneDecision(tier: .atelier, scene: .studio, placeName: identity.name,
                                 reason: "\(identity.name) için çizilmiş sokak yok · nötr atölye", attribution: nil)
    }

    public static func proceduralKey(_ identity: CityIdentity) -> String { "\(identity.countryCode):\(identity.matchKey)" }

    /// The owned street for a city, only when the country matches too (wrong-country guard).
    static func curated(for identity: CityIdentity) -> SceneCity? {
        FamousStreetCatalog.all.first { street in
            guard let owned = street.ownedScene, SceneAssetManifestV1.manifest(for: owned) != nil else { return false }
            return street.country == identity.countryCode && CityIdentity.fold(street.city) == identity.matchKey
        }?.ownedScene
    }
}

// MARK: - Sun (WP35-03)

/// Where the sun is, from date and place only (NOAA general solar position formulas, accurate to
/// about a degree, enough to choose a light). No network, no weather, no guess.
public enum SolarPosition {
    /// Solar elevation in degrees above the horizon (negative below), without refraction.
    public static func elevation(at date: Date, latitude: Double, longitude: Double) -> Double {
        let jd = date.timeIntervalSince1970 / 86400 + 2440587.5
        let t = (jd - 2451545) / 36525
        let l0 = (280.46646 + t * (36000.76983 + t * 0.0003032)).truncatingRemainder(dividingBy: 360)
        let m = 357.52911 + t * (35999.05029 - 0.0001537 * t)
        let e = 0.016708634 - t * (0.000042037 + 0.0000001267 * t)
        let mr = m * .pi / 180
        let c = sin(mr) * (1.914602 - t * (0.004817 + 0.000014 * t)) + sin(2 * mr) * (0.019993 - 0.000101 * t) + sin(3 * mr) * 0.000289
        let trueLong = l0 + c
        let omega = 125.04 - 1934.136 * t
        let lambda = trueLong - 0.00569 - 0.00478 * sin(omega * .pi / 180)
        let eps0 = 23 + (26 + (21.448 - t * (46.815 + t * (0.00059 - t * 0.001813))) / 60) / 60
        let eps = (eps0 + 0.00256 * cos(omega * .pi / 180)) * .pi / 180
        let decl = asin(sin(eps) * sin(lambda * .pi / 180))
        let y = pow(tan(eps / 2), 2)
        let l0r = l0 * .pi / 180
        let eqTime = 4 * (y * sin(2 * l0r) - 2 * e * sin(mr) + 4 * e * y * sin(mr) * cos(2 * l0r)
            - 0.5 * y * y * sin(4 * l0r) - 1.25 * e * e * sin(2 * mr)) * 180 / .pi
        let minutesUTC = date.timeIntervalSince1970.truncatingRemainder(dividingBy: 86400) / 60
        var trueSolarMinutes = (minutesUTC + eqTime + 4 * longitude).truncatingRemainder(dividingBy: 1440)
        if trueSolarMinutes < 0 { trueSolarMinutes += 1440 }
        let hourAngle = (trueSolarMinutes / 4 - 180) * .pi / 180
        let lat = latitude * .pi / 180
        let cosZenith = sin(lat) * sin(decl) + cos(lat) * cos(decl) * cos(hourAngle)
        return 90 - acos(min(max(cosZenith, -1), 1)) * 180 / .pi
    }
}

/// The light the scene uses, chosen from the sun only.
public enum LightPhase: String, Codable, Hashable, Sendable, CaseIterable {
    case day = "DAY"
    /// Sun low (under 6°): warm, long light.
    case goldenHour = "GOLDEN_HOUR"
    /// Civil twilight: sun just below the horizon.
    case twilight = "TWILIGHT"
    case night = "NIGHT"

    public static func at(_ date: Date, latitude: Double, longitude: Double) -> LightPhase {
        from(elevation: SolarPosition.elevation(at: date, latitude: latitude, longitude: longitude))
    }

    public static func from(elevation: Double) -> LightPhase {
        switch elevation {
        case 6...: .day
        case -0.833..<6: .goldenHour
        case -6 ..< -0.833: .twilight
        default: .night
        }
    }

    public var displayName: String {
        switch self {
        case .day: "Gündüz"
        case .goldenHour: "Altın saat"
        case .twilight: "Alacakaranlık"
        case .night: "Gece"
        }
    }

    /// Scene light: key strength, ambient strength and a warm/cool tint (0 cool … 1 warm).
    public var stageLight: (key: Float, ambient: Float, warmth: Float) {
        switch self {
        case .day: (1.0, 0.55, 0.5)
        case .goldenHour: (0.75, 0.4, 0.85)
        case .twilight: (0.35, 0.3, 0.25)
        case .night: (0.2, 0.22, 0.15)
        }
    }
}
