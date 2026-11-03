import Foundation

/// What the user can allow or take back (§112, §112.3). A scope that was never asked is not granted.
public enum ConsentScope: String, Codable, CaseIterable, Sendable {
    case photos = "PHOTOS"
    case location = "LOCATION"
    case learning = "LEARNING"
    case weatherFetch = "WEATHER_FETCH"
    case productLookup = "PRODUCT_LOOKUP"
    case streetImagery = "STREET_IMAGERY"

    /// Capabilities that stop working the moment this scope is revoked.
    public var dependentCapabilities: Set<Capability> {
        switch self {
        case .photos: [.photosReadUserSelected]
        case .location: []
        case .learning: [.learningUpdateLocal]
        case .weatherFetch: [.weatherFetch]
        case .productLookup: [.networkProductOnly]
        case .streetImagery: [.streetImageryFetch]
        }
    }
}

public enum ConsentState: String, Codable, Sendable {
    /// Never asked. Per-action egress (a tap) may still proceed; standing access may not.
    case notAsked = "NOT_ASKED"
    case granted = "GRANTED"
    /// The user switched it off. Nothing in this scope runs, not even on a tap.
    case revoked = "REVOKED"
}

/// The §112.3 revocation chain as data, so the app and tests walk the same steps.
public enum RevocationStep: String, Codable, Sendable {
    case cancelInFlightWork = "CANCEL_IN_FLIGHT_WORK"
    case stopFutureAccess = "STOP_FUTURE_ACCESS"
    case revokeUnapprovedAssetReferences = "REVOKE_UNAPPROVED_ASSET_REFERENCES"
    case purgeTransientPixelsAndEmbeddings = "PURGE_TRANSIENT_PIXELS_AND_EMBEDDINGS"
    case keepUserApprovedWardrobeItems = "KEEP_USER_APPROVED_WARDROBE_ITEMS"
    case fallBackToManualCity = "FALL_BACK_TO_MANUAL_CITY"
    case stopLocalUpdater = "STOP_LOCAL_UPDATER"
    case offerTrainingDataPurge = "OFFER_TRAINING_DATA_PURGE"
    case keepCachedForecastUntilExpiry = "KEEP_CACHED_FORECAST_UNTIL_EXPIRY"
    /// Street photo switched off: the owned 3D street (or the studio) takes its place.
    case fallBackToOwnedScene = "FALL_BACK_TO_OWNED_SCENE"
}

public struct RevocationPlan: Hashable, Sendable {
    public let scope: ConsentScope
    public let steps: [RevocationStep]
    public let invalidatedCapabilities: Set<Capability>
}

/// Device-local record of what the user allowed. Every change bumps `version`, which derived caches
/// carry so they can be invalidated by consent version (§116.2).
public struct ConsentLedger: Codable, Hashable, Sendable {
    public static let schemaVersion = 1

    public struct Entry: Codable, Hashable, Sendable {
        public let state: ConsentState
        public let changedAt: Date
    }

    public private(set) var entries: [ConsentScope: Entry]
    public private(set) var version: Int

    public init() {
        entries = [:]
        version = 0
    }

    public func state(_ scope: ConsentScope) -> ConsentState { entries[scope]?.state ?? .notAsked }

    public mutating func grant(_ scope: ConsentScope, at date: Date = Date()) {
        entries[scope] = Entry(state: .granted, changedAt: date)
        version += 1
    }

    @discardableResult
    public mutating func revoke(_ scope: ConsentScope, at date: Date = Date()) -> RevocationPlan {
        entries[scope] = Entry(state: .revoked, changedAt: date)
        version += 1
        return Self.plan(for: scope)
    }

    public static func plan(for scope: ConsentScope) -> RevocationPlan {
        let steps: [RevocationStep] = switch scope {
        case .photos: [.cancelInFlightWork, .stopFutureAccess, .revokeUnapprovedAssetReferences,
                       .purgeTransientPixelsAndEmbeddings, .keepUserApprovedWardrobeItems]
        case .location: [.stopFutureAccess, .fallBackToManualCity]
        case .learning: [.stopLocalUpdater, .offerTrainingDataPurge]
        case .weatherFetch: [.cancelInFlightWork, .stopFutureAccess, .keepCachedForecastUntilExpiry]
        case .productLookup: [.cancelInFlightWork, .stopFutureAccess]
        case .streetImagery: [.cancelInFlightWork, .stopFutureAccess, .fallBackToOwnedScene]
        }
        return RevocationPlan(scope: scope, steps: steps, invalidatedCapabilities: scope.dependentCapabilities)
    }
}
