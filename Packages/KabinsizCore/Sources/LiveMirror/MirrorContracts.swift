import DomainContracts
import DomainSchemas
import Foundation
import SystemContracts

/// LM21-WP03 contracts for the live mirror (ADR-008). Local is the default and only open mode; the cloud
/// mode exists as a contract so its gates can be tested, and stays switched off.
public enum MirrorMode: String, Codable, CaseIterable, Sendable {
    case local = "LOCAL"
    case cloudOptIn = "CLOUD_OPT_IN"
}

public enum MirrorStatus: String, Codable, CaseIterable, Sendable {
    case idle = "IDLE", requestingPermission = "REQUESTING_PERMISSION", preview = "PREVIEW", preflight = "PREFLIGHT"
    case connecting = "CONNECTING", live = "LIVE", degraded = "DEGRADED", stopping = "STOPPING", stopped = "STOPPED", failed = "FAILED"

    /// Nothing follows; a new try is a new session with its own checks (no silent reconnect, LM21-07.8).
    public var isTerminal: Bool { self == .stopped || self == .failed }

    /// The camera (and, in cloud mode, the remote session) may be open in this state.
    public var holdsCamera: Bool { [.preview, .preflight, .connecting, .live, .degraded, .stopping].contains(self) }
}

/// Why the picture got worse; the session keeps running with a visible note (LM21-06).
public enum DegradeReason: String, Codable, CaseIterable, Sendable {
    case deviceWarm = "DEVICE_WARM", lowPower = "LOW_POWER", frameDelayed = "FRAME_DELAYED"
    case poseOccluded = "POSE_OCCLUDED", weakConnection = "WEAK_CONNECTION"

    public var note: String {
        switch self {
        case .deviceWarm: "Telefon ısındı; görüntü sadeleştirildi."
        case .lowPower: "Düşük Güç Modu açık; görüntü sadeleştirildi."
        case .frameDelayed: "Görüntü gecikiyor."
        case .poseOccluded: "Vücudunun bir kısmı görünmüyor; giysi yerleşimi yaklaşık."
        case .weakConnection: "Bağlantı zayıf; görüntü sadeleştirildi."
        }
    }
}

/// Every way a session ends besides a fault. Each one really closes the camera and any remote session (LM21-07.8).
public enum StopReason: String, Codable, CaseIterable, Sendable {
    case userTapped = "USER_TAPPED", appBackground = "APP_BACKGROUND", screenLocked = "SCREEN_LOCKED"
    case incomingCall = "INCOMING_CALL", cameraPermissionRevoked = "CAMERA_PERMISSION_REVOKED"
    case maxDuration = "MAX_DURATION", costCap = "COST_CAP", networkLost = "NETWORK_LOST"
    case thermalCritical = "THERMAL_CRITICAL", productChanged = "PRODUCT_CHANGED"
}

/// Reason-coded failures. Raw values are persisted in audit events: never rename one.
public enum MirrorFault: String, Codable, CaseIterable, Sendable, Error {
    case permissionDenied = "PERMISSION_DENIED"
    case cameraUnavailable = "CAMERA_UNAVAILABLE"
    /// LM21-T04: an unknown or guessed product is never tried on as if it were the real variant.
    case productUnverified = "PRODUCT_UNVERIFIED"
    /// LM21-T05: several variants match; the user chooses first.
    case productAmbiguous = "PRODUCT_AMBIGUOUS"
    /// LM21-T06: product, catalogue, asset or body revision changed under the session.
    case staleRevision = "STALE_REVISION"
    /// ADR-008: the cloud mirror is switched off.
    case cloudDisabled = "CLOUD_DISABLED"
    case consentMissing = "CONSENT_MISSING"
    case budgetExceeded = "BUDGET_EXCEEDED"
    case deviceTooHot = "DEVICE_TOO_HOT"
    case networkUnsuitable = "NETWORK_UNSUITABLE"
    case providerFailed = "PROVIDER_FAILED"
    case invalidSpec = "INVALID_SPEC"

    /// Short Turkish text; no numbers, identifiers or private data.
    public var userMessage: String {
        switch self {
        case .permissionDenied: "Kamera izni yok. Ürün kartı yine kullanılabilir."
        case .cameraUnavailable: "Kamera şu an kullanılamıyor."
        case .productUnverified: "Bu ürün doğrulanmadı; aynada denenemez."
        case .productAmbiguous: "Birden fazla ürün eşleşti. Önce doğru olanı seç."
        case .staleRevision: "Ürün bilgisi değişti. Aynayı yeniden başlat."
        case .cloudDisabled: "Bulut ayna kapalı. Yerel ayna kullanılabilir."
        case .consentMissing: "Bu mod için onayın yok."
        case .budgetExceeded: "Süre ya da harcama sınırına ulaşıldı."
        case .deviceTooHot: "Telefon çok ısındı; canlı ayna kapatıldı. Ürün kartı açık."
        case .networkUnsuitable: "Bağlantı bu mod için uygun değil."
        case .providerFailed: "Ayna şu an çalışmıyor. Ürün kartı açık."
        case .invalidSpec: "Ayna başlatılamadı."
        }
    }

    public var faultCode: FaultCode {
        switch self {
        case .permissionDenied, .consentMissing: .capabilityNotGranted
        case .cameraUnavailable, .providerFailed: .moduleFailed
        case .productUnverified, .productAmbiguous: .dataRightsMissing
        case .staleRevision: .staleRevision
        case .cloudDisabled: .egressBlocked
        case .budgetExceeded, .deviceTooHot: .resourceDenied
        case .networkUnsuitable: .offline
        case .invalidSpec: .schemaInvalid
        }
    }
}

/// What the mirror shows, with the label the screen must carry (LM21-08). No level of it is fit evidence.
public enum MirrorFidelity: String, Codable, CaseIterable, Sendable {
    /// The camera picture with no garment drawn on it (no asset, or the device budget is 2D only).
    case cameraOnly = "CAMERA_ONLY"
    /// A prepared, licensed product asset drawn locally over the camera picture. Not cloth physics.
    case localGarmentOverlay = "LOCAL_GARMENT_OVERLAY"
    /// A generated video from a cloud model: logo, seams and pattern may change.
    case cloudGenerated = "CLOUD_GENERATED"

    public static let mayInformSizeAdvice = false

    public var tryOnFidelity: VisualTryOnV1.Fidelity {
        switch self {
        case .cameraOnly: .g0
        case .localGarmentOverlay: .g1
        case .cloudGenerated: .g3
        }
    }

    public var truthLabel: String {
        switch self {
        case .cameraOnly: "Yalnız kamera görüntüsü; giysi çizilmedi."
        case .localGarmentOverlay: "Yerel 3B giysi önizlemesi. Kumaş benzetimi değildir; beden uyumunun kanıtı değildir."
        case .cloudGenerated: "Yapay zekâyla üretilmiş görüntü. Logo, dikiş ve kalıp değişebilir; beden uyumunun kanıtı değildir."
        }
    }
}

/// One mirror session request. The revisions it names are the ones every frame must carry (LM21-T06).
public struct MirrorSessionSpec: Codable, Hashable, Sendable {
    public static let maxLocalSeconds = 1800
    /// LM21-11 / LM21-T23: paid cloud tries come in 10, 15 or 30 second packs.
    public static let cloudSecondsOptions: Set<Int> = [10, 15, 30]

    public var productVariantID: String
    /// `ProductIdentityV1.catalogVersion` the user saw when starting.
    public var catalogVersion: String
    public var assetRevision: Int?
    public var bodyProfileRevision: Int?
    public var requestedMode: MirrorMode
    public var maxDurationSeconds: Int
    public var consentRevision: Int?
    public var estimatedMaxCostUSD: Decimal?

    public init(productVariantID: String, catalogVersion: String, assetRevision: Int?, bodyProfileRevision: Int?, requestedMode: MirrorMode,
                maxDurationSeconds: Int, consentRevision: Int? = nil, estimatedMaxCostUSD: Decimal? = nil) {
        self.productVariantID = productVariantID
        self.catalogVersion = catalogVersion
        self.assetRevision = assetRevision
        self.bodyProfileRevision = bodyProfileRevision
        self.requestedMode = requestedMode
        self.maxDurationSeconds = maxDurationSeconds
        self.consentRevision = consentRevision
        self.estimatedMaxCostUSD = estimatedMaxCostUSD
    }

    enum CodingKeys: String, CodingKey {
        case productVariantID = "product_variant_id", catalogVersion = "catalog_version", assetRevision = "asset_revision"
        case bodyProfileRevision = "body_profile_revision", requestedMode = "requested_mode", maxDurationSeconds = "max_duration_seconds"
        case consentRevision = "consent_revision", estimatedMaxCostUSD = "estimated_max_cost_usd"
    }

    public func validate() throws(MirrorFault) {
        guard !productVariantID.trimmingCharacters(in: .whitespaces).isEmpty, !catalogVersion.trimmingCharacters(in: .whitespaces).isEmpty,
              assetRevision.map({ $0 >= 1 }) ?? true, bodyProfileRevision.map({ $0 >= 1 }) ?? true
        else { throw .invalidSpec }
        switch requestedMode {
        case .local:
            // Local costs nothing and needs no cloud consent; carrying either means the request is confused.
            guard (1...Self.maxLocalSeconds).contains(maxDurationSeconds), consentRevision == nil, estimatedMaxCostUSD == nil else { throw .invalidSpec }
        case .cloudOptIn:
            guard Self.cloudSecondsOptions.contains(maxDurationSeconds) else { throw .invalidSpec }
            guard let consentRevision, consentRevision >= 1 else { throw .consentMissing }
            // The price is shown before starting, so it must be known (LM21-T23).
            guard let cost = estimatedMaxCostUSD, cost > 0 else { throw .invalidSpec }
        }
    }
}
