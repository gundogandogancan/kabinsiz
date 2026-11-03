import Foundation

/// Where the home world is set (v2.5 §3.1). Chosen by the user; no location is needed or read.
public enum SceneCity: String, Codable, CaseIterable, Sendable, Identifiable {
    case istanbul = "TR-IST"
    case barcelona = "ES-BCN"
    case studio = "STUDIO"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .istanbul: "İstanbul"
        case .barcelona: "Barcelona"
        case .studio: "Stüdyo"
        }
    }

    /// What the backdrop evokes, said plainly: an original drawing, not a photo of an exact place.
    public var sceneDescription: String {
        switch self {
        case .istanbul: "Galata çevresi · özgün çizim"
        case .barcelona: "Eixample · özgün çizim"
        case .studio: "Nötr stüdyo"
        }
    }
}

/// Rights of a scene asset. Only owned or licensed assets ship (v2.5 §3.2).
public enum AssetProvenance: String, Codable, Sendable {
    /// Built by this project from primitives (tools/scenes); no third-party content.
    case ownedOriginal = "OWNED_ORIGINAL"
    case licensed = "LICENSED"
    case userSupplied = "USER_SUPPLIED"
}

/// One backdrop and its rights (v2.5 §3.2 SceneAssetManifestV1).
public struct SceneAssetManifestV1: Codable, Hashable, Sendable {
    public let cityID: SceneCity
    public let sceneID: String
    public let revision: String
    public let provenance: AssetProvenance
    public let approximateLandmark: String?
    /// Backdrop image per surface state.
    public let dryBackdrop: String
    public let wetBackdrop: String
    /// The look of the light in the render; never a claim about the current time of day.
    public let renderedLight: RenderedLight
    public let generator: String

    public enum RenderedLight: String, Codable, Sendable { case evening = "EVENING", day = "DAY", studio = "STUDIO" }

    public init(cityID: SceneCity, sceneID: String, revision: String, provenance: AssetProvenance, approximateLandmark: String?,
                dryBackdrop: String, wetBackdrop: String, renderedLight: RenderedLight, generator: String) {
        self.cityID = cityID
        self.sceneID = sceneID
        self.revision = revision
        self.provenance = provenance
        self.approximateLandmark = approximateLandmark
        self.dryBackdrop = dryBackdrop
        self.wetBackdrop = wetBackdrop
        self.renderedLight = renderedLight
        self.generator = generator
    }

    /// The scenes that ship. Both are rendered by tools/scenes/build_city_scene.py from primitives.
    public static let pilots: [SceneAssetManifestV1] = [
        SceneAssetManifestV1(cityID: .istanbul, sceneID: "galata-street-01", revision: "2026-11-03.1", provenance: .ownedOriginal,
                             approximateLandmark: "Galata çevresi (temsili kule)", dryBackdrop: "scene-istanbul-dry", wetBackdrop: "scene-istanbul-wet",
                             renderedLight: .evening, generator: "tools/scenes/build_city_scene.py --city istanbul"),
        SceneAssetManifestV1(cityID: .barcelona, sceneID: "eixample-street-01", revision: "2026-11-03.1", provenance: .ownedOriginal,
                             approximateLandmark: nil, dryBackdrop: "scene-barcelona-dry", wetBackdrop: "scene-barcelona-wet",
                             renderedLight: .day, generator: "tools/scenes/build_city_scene.py --city barcelona"),
    ]

    public static func manifest(for city: SceneCity) -> SceneAssetManifestV1? { pilots.first { $0.cityID == city } }
}

/// Why the scene shows the weather it shows (v2.5 §3.3). Rain is drawn only for an observation or an
/// explicit user preview; a forecast probability alone never makes it rain on screen.
public enum SceneWeatherEvidence: Codable, Hashable, Sendable {
    /// No weather data (the default: WeatherKit is not connected in this build).
    case none
    /// The user asked to preview a condition. Always labelled as a preview.
    case userPreview(SceneCondition)
    /// A dated observation from a consented provider.
    case observed(SceneCondition, source: String, at: Date)
    /// Only a probability for the day: shown as text, not as rain on screen.
    case probability(rainPercent: Int, source: String, at: Date)
}

public enum SceneCondition: String, Codable, CaseIterable, Sendable {
    case clear = "CLEAR", rain = "RAIN"
}

/// What the scene draws, decided from evidence only.
public struct SceneWeatherState: Codable, Hashable, Sendable {
    public let rainIntensity: Float
    public let wetGround: Bool
    /// One line for the top bar. Never a temperature that was not measured.
    public let label: String
    public let isPreview: Bool

    public static func from(_ evidence: SceneWeatherEvidence, now: Date = Date(), staleAfter: TimeInterval = 3 * 3600) -> SceneWeatherState {
        switch evidence {
        case .none:
            return SceneWeatherState(rainIntensity: 0, wetGround: false, label: "Hava verisi yok", isPreview: false)
        case let .userPreview(condition):
            return condition == .rain
                ? SceneWeatherState(rainIntensity: 1, wetGround: true, label: "Yağmur önizlemesi · gerçek hava değil", isPreview: true)
                : SceneWeatherState(rainIntensity: 0, wetGround: false, label: "Açık hava önizlemesi · gerçek hava değil", isPreview: true)
        case let .observed(condition, source, at):
            guard now.timeIntervalSince(at) <= staleAfter else {
                return SceneWeatherState(rainIntensity: 0, wetGround: false, label: "Hava verisi eski (\(source))", isPreview: false)
            }
            return condition == .rain
                ? SceneWeatherState(rainIntensity: 1, wetGround: true, label: "Yağmurlu · \(source)", isPreview: false)
                : SceneWeatherState(rainIntensity: 0, wetGround: false, label: "Açık · \(source)", isPreview: false)
        case let .probability(percent, source, _):
            return SceneWeatherState(rainIntensity: 0, wetGround: false, label: "Yağmur ihtimali %\(percent) · \(source)", isPreview: false)
        }
    }
}
