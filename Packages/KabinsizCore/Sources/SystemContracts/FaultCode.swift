import Foundation

/// Stable machine-readable failure reasons. Raw values are part of the persisted contract: never rename one.
public enum FaultCode: String, Codable, CaseIterable, Sendable, Error {
    case policyDenied = "POLICY_DENIED"
    case capabilityNotGranted = "CAPABILITY_NOT_GRANTED"
    case unknownModule = "UNKNOWN_MODULE"
    case schemaInvalid = "SCHEMA_INVALID"
    case schemaNewer = "SCHEMA_NEWER"
    case staleRevision = "STALE_REVISION"
    case duplicateEvent = "DUPLICATE_EVENT"
    case invalidTransition = "INVALID_TRANSITION"
    case timedOut = "TIMED_OUT"
    case cancelled = "CANCELLED"
    case moduleFailed = "MODULE_FAILED"
    case resourceDenied = "RESOURCE_DENIED"
    case egressBlocked = "EGRESS_BLOCKED"
    case unknownClassification = "UNKNOWN_CLASSIFICATION"
    case dataRightsMissing = "DATA_RIGHTS_MISSING"
    case storageCorrupted = "STORAGE_CORRUPTED"
    case offline = "OFFLINE"

    /// Whether trying the same thing again later can succeed without the user changing anything.
    public var isRetryable: Bool {
        switch self {
        case .timedOut, .resourceDenied, .offline, .moduleFailed: true
        default: false
        }
    }

    /// Short Turkish text for the UI. Never contains private data or internal identifiers.
    public var userMessage: String {
        switch self {
        case .policyDenied, .capabilityNotGranted, .unknownModule: "Bu işlem için izin yok."
        case .schemaInvalid, .schemaNewer, .storageCorrupted: "Kayıtlı veri okunamadı. Hiçbir şey silinmedi."
        case .staleRevision, .duplicateEvent: "Daha yeni bir değişiklik zaten kaydedildi."
        case .invalidTransition: "Bu işlem artık değiştirilemez."
        case .timedOut: "İşlem zaman aşımına uğradı. Basit görünüm gösteriliyor."
        case .cancelled: "İşlem iptal edildi."
        case .moduleFailed: "Bu bölüm şu an çalışmıyor. Uygulamanın geri kalanı kullanılabilir."
        case .resourceDenied: "Cihaz yoğun. Daha hafif bir görünüm kullanılıyor."
        case .egressBlocked, .unknownClassification: "Bu veri cihazından çıkamaz."
        case .dataRightsMissing: "Bu bilgi için kullanım hakkı yok; gösterilmiyor."
        case .offline: "Çevrimdışısın. Kayıtlı bilgiler gösteriliyor."
        }
    }
}
