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
    /// The real-time 3D street, when one ships for this city (v2.8 UI28-05). Nil means only the 2D frame.
    public let model3D: CityModel3D?

    public enum RenderedLight: String, Codable, Sendable { case evening = "EVENING", day = "DAY", studio = "STUDIO" }

    public init(cityID: SceneCity, sceneID: String, revision: String, provenance: AssetProvenance, approximateLandmark: String?,
                dryBackdrop: String, wetBackdrop: String, renderedLight: RenderedLight, generator: String, model3D: CityModel3D? = nil) {
        self.cityID = cityID
        self.sceneID = sceneID
        self.revision = revision
        self.provenance = provenance
        self.approximateLandmark = approximateLandmark
        self.dryBackdrop = dryBackdrop
        self.wetBackdrop = wetBackdrop
        self.renderedLight = renderedLight
        self.generator = generator
        self.model3D = model3D
    }

    /// The scenes that ship. Both are rendered by tools/scenes/build_city_scene.py from primitives.
    public static let pilots: [SceneAssetManifestV1] = [
        SceneAssetManifestV1(cityID: .istanbul, sceneID: "galata-street-01", revision: "2026-11-03.1", provenance: .ownedOriginal,
                             approximateLandmark: "Galata çevresi (temsili kule)", dryBackdrop: "scene-istanbul-dry", wetBackdrop: "scene-istanbul-wet",
                             renderedLight: .evening, generator: "tools/scenes/build_city_scene.py --city istanbul",
                             model3D: CityModel3D(resource: "city-istanbul", revision: "2026-11-04.1")),
        SceneAssetManifestV1(cityID: .barcelona, sceneID: "eixample-street-01", revision: "2026-11-03.1", provenance: .ownedOriginal,
                             approximateLandmark: nil, dryBackdrop: "scene-barcelona-dry", wetBackdrop: "scene-barcelona-wet",
                             renderedLight: .day, generator: "tools/scenes/build_city_scene.py --city barcelona",
                             model3D: CityModel3D(resource: "city-barcelona", revision: "2026-11-04.1")),
    ]

    public static func manifest(for city: SceneCity) -> SceneAssetManifestV1? { pilots.first { $0.cityID == city } }
}

/// A street built as geometry (tools/scenes/build_city_usdz.py): meshes RealityKit draws from the app
/// camera, with lighting precomputed in Blender for that camera. Depth, occlusion, parallax and rain
/// are real time; the light is not, and the app says so.
public struct CityModel3D: Codable, Hashable, Sendable {
    /// USDZ in the app bundle, without extension. Its rights file is `<resource>.asset-rights.json`.
    public let resource: String
    public let revision: String
    /// Mesh groups inside the USDZ; each has a baked texture per surface state.
    public static let groups = ["near", "ground", "left", "right", "far", "sky"]

    public init(resource: String, revision: String) {
        self.resource = resource
        self.revision = revision
    }

    /// The baked texture of one group for a surface state, e.g. `city-istanbul-ground-wet` (a JPEG).
    public func texture(group: String, wet: Bool) -> String { "\(resource)-\(group)-\(wet ? "wet" : "dry")" }
}

/// How the city is drawn right now (v2.8 §06.8: an fps and thermal governor, never a silent fake).
public enum SceneRenderTier: String, Codable, Sendable, CaseIterable {
    /// The 3D street at full quality.
    case city3D = "CITY_3D"
    /// The 3D street with less rain and no camera drift (heat, low power or slow frames).
    case city3DReduced = "CITY_3D_REDUCED"
    /// The labelled 2D Blender frame behind the 3D figure.
    case frame2D = "FRAME_2D"
    /// Apple Look Around imagery of a catalogue street behind the 3D figure (a photo, not 3D).
    case streetPhoto = "STREET_PHOTO"
}

public enum ThermalLevel: Int, Codable, Sendable, Comparable {
    case nominal, fair, serious, critical
    public static func < (a: ThermalLevel, b: ThermalLevel) -> Bool { a.rawValue < b.rawValue }
}

public struct SceneQuality: Equatable, Sendable {
    public let tier: SceneRenderTier
    /// Multiplier on the rain particle rate.
    public let rainScale: Float
    /// Slow sideways camera drift that shows the street's depth; off for Reduce Motion and when reduced.
    public let cameraDrift: Bool
    public let reason: String

    public init(tier: SceneRenderTier, rainScale: Float, cameraDrift: Bool, reason: String) {
        self.tier = tier
        self.rainScale = rainScale
        self.cameraDrift = cameraDrift
        self.reason = reason
    }
}

/// Picks the render tier from what the device reports. Pure, so every branch is unit-tested.
public enum SceneQualityPolicy {
    /// Below this sustained rate the 3D street is reduced; below `frameFloor` it gives way to the 2D frame.
    public static let reduceBelowFPS = 45.0
    public static let frameFloorFPS = 24.0

    public static func decide(hasModel: Bool, loadFailed: Bool, thermal: ThermalLevel, lowPower: Bool,
                              reduceMotion: Bool, sustainedFPS: Double?) -> SceneQuality {
        guard hasModel else { return SceneQuality(tier: .frame2D, rainScale: 1, cameraDrift: false, reason: "Bu şehir için 3B sokak yok") }
        if loadFailed { return SceneQuality(tier: .frame2D, rainScale: 1, cameraDrift: false, reason: "3B sokak yüklenemedi") }
        if thermal == .critical { return SceneQuality(tier: .frame2D, rainScale: 0.3, cameraDrift: false, reason: "Cihaz çok ısındı") }
        if let fps = sustainedFPS, fps < frameFloorFPS {
            return SceneQuality(tier: .frame2D, rainScale: 0.5, cameraDrift: false, reason: "Kare hızı düşük")
        }
        if thermal == .serious || lowPower || (sustainedFPS.map { $0 < reduceBelowFPS } ?? false) {
            let why = thermal == .serious ? "Cihaz ısındı" : lowPower ? "Düşük güç modu" : "Kare hızı düşük"
            return SceneQuality(tier: .city3DReduced, rainScale: 0.35, cameraDrift: false, reason: why)
        }
        return SceneQuality(tier: .city3D, rainScale: 1, cameraDrift: !reduceMotion, reason: "Tam kalite")
    }

    /// The truth line when no city scene is chosen (the neutral studio).
    public static let studioLine = "Temsili 3B giysi · nötr stüdyo · beden uyumunu göstermez"

    /// The truth line under the home controls: what is 3D and what is not, and no fit claim.
    public static func truthLine(_ tier: SceneRenderTier) -> String {
        switch tier {
        case .city3D, .city3DReduced: "Temsili 3B giysi · 3B şehir, hazır ışık · beden uyumunu göstermez"
        case .frame2D: "Temsili 3B giysi · şehir Blender kadrajı · beden uyumunu göstermez"
        case .streetPhoto: "Temsili 3B giysi · cadde fotoğrafı: Apple · beden uyumunu göstermez"
        }
    }
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
    case clear = "CLEAR", cloudy = "CLOUDY", rain = "RAIN", snow = "SNOW", wind = "WIND", fog = "FOG"

    public var displayName: String {
        switch self {
        case .clear: "Açık"
        case .cloudy: "Bulutlu"
        case .rain: "Yağmur"
        case .snow: "Kar"
        case .wind: "Rüzgârlı"
        case .fog: "Sisli"
        }
    }

    public var symbolName: String {
        switch self {
        case .clear: "sun.max"
        case .cloudy: "cloud"
        case .rain: "cloud.rain"
        case .snow: "cloud.snow"
        case .wind: "wind"
        case .fog: "cloud.fog"
        }
    }
}

/// What the scene draws, decided from evidence only. Wind moves the environment (leaves, particles,
/// rain slant) and never the garments or the figure (ADR-016: nothing on the model moves by itself).
public struct SceneWeatherState: Codable, Hashable, Sendable {
    public let rainIntensity: Float
    public let wetGround: Bool
    /// One line for the top bar. Never a temperature that was not measured.
    public let label: String
    public let isPreview: Bool
    public let snowIntensity: Float
    /// 0 clear sky … 1 overcast: dims the key light and greys the sky.
    public let cloudCover: Float
    /// Environment only: particle drift and rain slant. 0 … 1.
    public let windStrength: Float
    public let fogDensity: Float
    /// The condition drawn, or nil when nothing is drawn (no data, stale, probability only).
    public let drawn: SceneCondition?

    public init(rainIntensity: Float, wetGround: Bool, label: String, isPreview: Bool, snowIntensity: Float = 0,
                cloudCover: Float = 0, windStrength: Float = 0, fogDensity: Float = 0, drawn: SceneCondition? = nil) {
        self.rainIntensity = rainIntensity
        self.wetGround = wetGround
        self.label = label
        self.isPreview = isPreview
        self.snowIntensity = snowIntensity
        self.cloudCover = cloudCover
        self.windStrength = windStrength
        self.fogDensity = fogDensity
        self.drawn = drawn
    }

    /// The drawing for one condition; `label` and `isPreview` say why it is drawn.
    static func drawing(_ c: SceneCondition, label: String, isPreview: Bool) -> SceneWeatherState {
        switch c {
        case .clear: SceneWeatherState(rainIntensity: 0, wetGround: false, label: label, isPreview: isPreview, drawn: c)
        case .cloudy: SceneWeatherState(rainIntensity: 0, wetGround: false, label: label, isPreview: isPreview, cloudCover: 0.8, drawn: c)
        case .rain: SceneWeatherState(rainIntensity: 1, wetGround: true, label: label, isPreview: isPreview, cloudCover: 1, windStrength: 0.15, drawn: c)
        case .snow: SceneWeatherState(rainIntensity: 0, wetGround: false, label: label, isPreview: isPreview, snowIntensity: 1, cloudCover: 0.9, windStrength: 0.1, drawn: c)
        case .wind: SceneWeatherState(rainIntensity: 0, wetGround: false, label: label, isPreview: isPreview, cloudCover: 0.4, windStrength: 1, drawn: c)
        case .fog: SceneWeatherState(rainIntensity: 0, wetGround: false, label: label, isPreview: isPreview, cloudCover: 0.6, fogDensity: 1, drawn: c)
        }
    }

    public static func from(_ evidence: SceneWeatherEvidence, now: Date = Date(), staleAfter: TimeInterval = 3 * 3600) -> SceneWeatherState {
        switch evidence {
        case .none:
            return SceneWeatherState(rainIntensity: 0, wetGround: false, label: "Hava verisi yok", isPreview: false)
        case let .userPreview(condition):
            return drawing(condition, label: "\(condition.displayName) önizlemesi · gerçek hava değil", isPreview: true)
        case let .observed(condition, source, at):
            guard now.timeIntervalSince(at) <= staleAfter else {
                return SceneWeatherState(rainIntensity: 0, wetGround: false, label: "Hava verisi eski (\(source))", isPreview: false)
            }
            return drawing(condition, label: "\(condition == .rain ? "Yağmurlu" : condition.displayName) · \(source)", isPreview: false)
        case let .probability(percent, source, _):
            return SceneWeatherState(rainIntensity: 0, wetGround: false, label: "Yağmur ihtimali %\(percent) · \(source)", isPreview: false)
        }
    }
}
