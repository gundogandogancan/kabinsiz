import Foundation

/// Data classes every field, event payload and egress request must carry (§101.1, §112.2).
/// Decoding an unknown class fails: an unclassified value is never treated as public (fail closed).
public enum DataClassification: String, Codable, CaseIterable, Sendable {
    /// Public product facts: GTIN, model code, catalog attributes. The only class allowed off-device by default.
    case publicProduct = "PUBLIC_PRODUCT"
    /// User data that stays on device: wardrobe, trips, preferences (INV-01).
    case localPrivate = "LOCAL_PRIVATE"
    /// Body measurements, avatar geometry, person photos. Never leaves the device in P0 (INV-01, INV-03).
    case localSensitive = "LOCAL_SENSITIVE"
    /// Counters with no personal content, only when diagnostics are enabled (§118).
    case redactedDiagnostic = "REDACTED_DIAGNOSTIC"
    /// Test and demo data, labelled `SYNTHETIC_DEMO_ONLY` in the UI.
    case syntheticFixture = "SYNTHETIC_FIXTURE"

    public var mayLeaveDeviceByDefault: Bool { self == .publicProduct }
}

/// Restricted resources from §112. There is deliberately no wildcard case.
public enum Capability: String, Codable, CaseIterable, Sendable {
    case bodyReadExact = "body.readExact"
    case bodyWriteManual = "body.writeManual"
    case avatarReadRenderSnapshot = "avatar.readRenderSnapshot"
    case photosReadUserSelected = "photos.readUserSelected"
    case wardrobeRead = "wardrobe.read"
    case wardrobeWrite = "wardrobe.write"
    case travelReadPrivate = "travel.readPrivate"
    case catalogReadLicensed = "catalog.readLicensed"
    case weatherFetch = "weather.fetch"
    /// One Apple Look Around scene for a catalogue street (EG-002). Never the device position.
    case streetImageryFetch = "streetImagery.fetch"
    case networkProductOnly = "network.productOnly"
    case vaultExport = "vault.export"
    case vaultDelete = "vault.delete"
    case learningUpdateLocal = "learning.updateLocal"
    case modelActivateSigned = "model.activateSigned"
    case retailWriteTenant = "retail.writeTenant"
    case diagnosticsReadRedacted = "diagnostics.readRedacted"

    /// Capabilities that open a network path. Granting one always needs an `EgressIntent` as well.
    public var isNetwork: Bool { self == .networkProductOnly || self == .weatherFetch || self == .streetImageryFetch }
}

/// Runtime specialist IDs from §104.1. An ID existing here does not mean the module is registered.
public enum ModuleID: String, Codable, CaseIterable, Sendable {
    case intentInterpreter = "OCT-01", consentGuardian = "OCT-02", deviceGovernor = "OCT-03", photoIntake = "OCT-04"
    case garmentVision = "OCT-05", bodyLandmarkLab = "OCT-06", bodyGeometry = "OCT-07", avatarRenderer = "OCT-08"
    case productIdentifier = "OCT-09", brandDataResolver = "OCT-10", materialAnalyst = "OCT-11", fitSpecialist = "OCT-12"
    case visualTryOn = "OCT-13", styleDirector = "OCT-14", colorCoordinator = "OCT-15", weatherContext = "OCT-16"
    case occasionVenue = "OCT-17", wardrobeSteward = "OCT-18", capsuleTravelPlanner = "OCT-19", fitMemoryLearner = "OCT-20"
    case knowledgeProvenance = "OCT-21", explanation = "OCT-22", retailPrivacyGateway = "OCT-23", healthIntegrityWatch = "OCT-24"
}
