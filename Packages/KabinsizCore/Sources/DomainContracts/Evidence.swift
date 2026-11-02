import Foundation

/// How sure a recommendation is allowed to sound. No numeric confidence is ever shown (§60.2).
public enum ConfidenceKind: String, Codable, Sendable {
    case verifiedFacts = "VERIFIED_FACTS"
    case heuristic = "HEURISTIC"
    case partial = "PARTIAL"
    case abstain = "ABSTAIN"
}

/// Visual fidelity ladder (§25.2, §63.2). P0 only ships the 2D tier.
public enum VisualFidelityTier: String, Codable, Sendable {
    case flat2D = "2D_CARD"
    case genericMesh = "G0_GENERIC"
    case productAsset = "G1_PRODUCT_ASSET"

    public var displayName: String {
        switch self {
        case .flat2D: "2D kart (3D yok)"
        case .genericMesh: "Genel örnek 3D (ürüne özel değil)"
        case .productAsset: "Ürüne özel 3D varlık"
        }
    }
}

/// Feature status vocabulary used in evidence reports (§74.1).
public enum FeatureStatus: String, Codable, Sendable {
    case specOnly = "SPEC_ONLY", coded = "CODED", tested = "TESTED", deviceVerified = "DEVICE_VERIFIED"
    case userValidated = "USER_VALIDATED", livePartner = "LIVE_PARTNER", blocked = "BLOCKED"
}
