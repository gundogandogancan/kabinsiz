import Foundation

/// A time-limited permission for one module to use one capability, issued because of a user action
/// (§112: "grant based on user purpose and module identity, with expiry/one-shot semantics").
public struct CapabilityGrant: Hashable, Sendable {
    public let id: UUID
    public let module: ModuleID
    public let capability: Capability
    public let issuedAt: Date
    public let expiresAt: Date
    public let oneShot: Bool
}

/// Outgoing DTOs say what class of data they carry. `nil` means nobody classified the DTO, and the
/// gate refuses it before anything is serialised for the network (V15-T-SEC-07).
public protocol EgressPayload: Encodable, Sendable {
    static var egressClassification: DataClassification? { get }
}

/// One destination the app may reach, mirrored in `docs/security/EGRESS_REGISTER.md`.
public struct EgressRoute: Hashable, Sendable {
    public let registerID: String
    public let host: String
    public let method: EgressIntent.Method
    public let path: String
    public let purpose: EgressIntent.Purpose

    /// Public for tests. The app never builds a route itself (enforced by the source scan).
    public init(registerID: String, host: String, method: EgressIntent.Method, path: String, purpose: EgressIntent.Purpose) {
        self.registerID = registerID
        self.host = host
        self.method = method
        self.path = path
        self.purpose = purpose
    }

    /// The complete allowlist. A host or path missing here cannot be reached through the gate, whatever
    /// an intent declares (V15-T-SEC-06).
    public static let registered: [EgressRoute] = [
        EgressRoute(registerID: "EG-001", host: "weatherkit.apple.com", method: .get, path: "/api/v1/weather", purpose: .weatherForecast),
        // MapKit makes the HTTP call itself and picks Apple's hosts; this entry names the framework call
        // the gate authorises (a MapKit Look Around scene request for one catalogue point), see EGRESS_REGISTER.md.
        EgressRoute(registerID: "EG-003", host: "mapkit.apple.com", method: .get, path: "/look-around/scene", purpose: .streetImagery),
    ]
}

/// Proof that the gate checked this exact request. Only the gate can make one, so a transport that
/// takes it cannot be called with an unchecked payload. `fields` are the wire values that were checked.
public struct AuthorizedEgress: Sendable {
    public let intent: EgressIntent
    public let fields: [String: String]
    public let grantID: UUID
    public let authorizedAt: Date

    fileprivate init(intent: EgressIntent, fields: [String: String], grantID: UUID, authorizedAt: Date) {
        self.intent = intent
        self.fields = fields
        self.grantID = grantID
        self.authorizedAt = authorizedAt
    }
}

/// Redacted log line: field names only, never values (§111.2 "never log ... private IDs").
public struct EgressAuditEntry: Hashable, Sendable {
    public enum Outcome: Hashable, Sendable {
        case sent
        case blocked(FaultCode)
        /// The response arrived after the user revoked consent and was thrown away.
        case discardedAfterRevocation
    }

    public let date: Date
    public let purpose: EgressIntent.Purpose
    public let host: String
    public let fieldNames: [String]
    public let outcome: Outcome
}

/// Runtime half of CITADEL (§110, §112): module capabilities, consent and the single egress path.
/// Every check fails closed. Static source scans (StoreAndPrivacyTests) keep other networking out.
public actor CitadelGate {
    public static let maxAuditEntries = 200
    /// Short on purpose: a grant covers one tap, not a session.
    public static let defaultGrantLifetime: TimeInterval = 60
    /// No grant lives longer than this, so a grant cannot stand in for standing consent.
    public static let maxGrantLifetime: TimeInterval = 60

    private let registry: ModuleRegistry
    private let routes: Set<EgressRoute>
    private let clock: @Sendable () -> Date
    public private(set) var ledger: ConsentLedger
    private var grants: [UUID: CapabilityGrant] = [:]
    /// Bumped on every revocation, so work that was in flight can tell it was overtaken.
    private var revocationEpoch: [ConsentScope: Int] = [:]
    public private(set) var audit: [EgressAuditEntry] = []

    public init(
        registry: ModuleRegistry, ledger: ConsentLedger = ConsentLedger(),
        routes: [EgressRoute] = EgressRoute.registered, clock: @escaping @Sendable () -> Date = Date.init
    ) {
        self.registry = registry
        self.ledger = ledger
        self.routes = Set(routes)
        self.clock = clock
    }

    // MARK: Consent

    public func grantConsent(_ scope: ConsentScope) { ledger.grant(scope, at: clock()) }

    /// Runs the revocation chain: grants for dependent capabilities die now, and anything in flight for
    /// this scope will be discarded when it returns (§112.3).
    @discardableResult
    public func revokeConsent(_ scope: ConsentScope) -> RevocationPlan {
        let plan = ledger.revoke(scope, at: clock())
        grants = grants.filter { !plan.invalidatedCapabilities.contains($0.value.capability) }
        revocationEpoch[scope, default: 0] += 1
        return plan
    }

    // MARK: Capabilities

    /// Issued in response to a user action. Unknown module, a capability outside the module's
    /// registry entry, or a revoked scope → denied.
    public func issue(
        module: ModuleID, capability: Capability, lifetime: TimeInterval = defaultGrantLifetime, oneShot: Bool = true
    ) throws(FaultCode) -> CapabilityGrant {
        guard lifetime > 0, lifetime <= Self.maxGrantLifetime else { throw .policyDenied }
        if case .denied(let fault) = registry.decide(module: module, capability: capability) { throw fault }
        if let scope = Self.scope(for: capability), ledger.state(scope) == .revoked { throw .policyDenied }
        let now = clock()
        // A network grant always covers exactly one request, whatever the caller asked for.
        let grant = CapabilityGrant(id: UUID(), module: module, capability: capability, issuedAt: now,
                                    expiresAt: now.addingTimeInterval(lifetime), oneShot: oneShot || capability.isNetwork)
        grants[grant.id] = grant
        return grant
    }

    /// Checks a grant for this exact module and capability, consuming it if it is one-shot.
    public func use(_ grant: CapabilityGrant, module: ModuleID, capability: Capability) throws(FaultCode) {
        guard let stored = grants[grant.id], stored == grant, stored.module == module, stored.capability == capability
        else { throw .capabilityNotGranted }
        guard clock() < stored.expiresAt else {
            grants[grant.id] = nil
            throw .capabilityNotGranted
        }
        // The registry is checked again: a grant never outlives the module's own entry.
        if case .denied(let fault) = registry.decide(module: module, capability: capability) { throw fault }
        if let scope = Self.scope(for: capability), ledger.state(scope) == .revoked { throw .policyDenied }
        if stored.oneShot { grants[grant.id] = nil }
    }

    public var activeGrantCount: Int { grants.count }

    // MARK: Egress

    /// The only way a request leaves the app. Order: declaration → route allowlist → module capability
    /// → consent and grant → DTO class → wire fields. The transport runs only if all pass, and its
    /// result is discarded if consent was revoked while it ran.
    public func send<Payload: EgressPayload, Result: Sendable>(
        _ intent: EgressIntent, payload: Payload, module: ModuleID, grant: CapabilityGrant,
        transport: @Sendable (AuthorizedEgress) async throws -> Result
    ) async throws -> Result {
        let authorized: AuthorizedEgress
        do {
            authorized = try authorize(intent, payload: payload, module: module, grant: grant)
        } catch {
            record(intent, outcome: .blocked(error))
            throw error
        }
        let scope = Self.scope(for: intent.purpose)
        let epoch = revocationEpoch[scope, default: 0]
        let result = try await transport(authorized)
        guard revocationEpoch[scope, default: 0] == epoch, ledger.state(scope) != .revoked else {
            record(intent, outcome: .discardedAfterRevocation)
            throw FaultCode.policyDenied
        }
        record(intent, outcome: .sent)
        return result
    }

    private func authorize<Payload: EgressPayload>(
        _ intent: EgressIntent, payload: Payload, module: ModuleID, grant: CapabilityGrant
    ) throws(FaultCode) -> AuthorizedEgress {
        try intent.validate()
        let route = EgressRoute(registerID: "", host: intent.destinationHost, method: intent.method,
                                path: intent.endpointPath, purpose: intent.purpose)
        guard routes.contains(where: { $0.host == route.host && $0.method == route.method && $0.path == route.path && $0.purpose == route.purpose })
        else { throw .egressBlocked }
        let capability = Self.capability(for: intent.purpose)
        try use(grant, module: module, capability: capability)
        guard let declared = Payload.egressClassification else { throw .unknownClassification }
        guard declared == intent.classification else { throw .egressBlocked }
        let fields = try Self.wireFields(payload, declared: intent.fields)
        return AuthorizedEgress(intent: intent, fields: fields, grantID: grant.id, authorizedAt: clock())
    }

    private func record(_ intent: EgressIntent, outcome: EgressAuditEntry.Outcome) {
        audit.append(EgressAuditEntry(date: clock(), purpose: intent.purpose, host: intent.destinationHost,
                                      fieldNames: intent.fields.sorted(), outcome: outcome))
        if audit.count > Self.maxAuditEntries { audit.removeFirst(audit.count - Self.maxAuditEntries) }
    }

    // MARK: Wire check

    public static let maxWireValueLength = 64

    /// Serialises the DTO exactly as it would go out and compares it with the declaration: same keys,
    /// flat scalar values, short plain text. An extra key (a waist size that slipped into a product
    /// request) or a nested object fails the request (V15-T-SEC-08).
    static func wireFields(_ payload: some Encodable, declared: [String]) throws(FaultCode) -> [String: String] {
        let object: Any
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            object = try JSONSerialization.jsonObject(with: encoder.encode(payload))
        } catch {
            throw .schemaInvalid
        }
        guard let dict = object as? [String: Any], Set(dict.keys) == Set(declared) else { throw .egressBlocked }
        var out: [String: String] = [:]
        for (key, value) in dict {
            switch value {
            case let number as NSNumber where CFGetTypeID(number) != CFBooleanGetTypeID():
                out[key] = number.stringValue
            case let text as String where isPlainWireText(text):
                out[key] = text
            default:
                throw .egressBlocked
            }
        }
        return out
    }

    static func isPlainWireText(_ text: String) -> Bool {
        guard !text.isEmpty, text.count <= maxWireValueLength else { return false }
        return text.unicodeScalars.allSatisfy { s in
            s.isASCII && (CharacterSet.alphanumerics.contains(s) || " .,_:-".unicodeScalars.contains(s))
        }
    }

    // MARK: Mappings

    static func capability(for purpose: EgressIntent.Purpose) -> Capability {
        switch purpose {
        case .productLookup: .networkProductOnly
        case .weatherForecast: .weatherFetch
        case .streetImagery: .streetImageryFetch
        }
    }

    static func scope(for purpose: EgressIntent.Purpose) -> ConsentScope {
        switch purpose {
        case .productLookup: .productLookup
        case .weatherForecast: .weatherFetch
        case .streetImagery: .streetImagery
        }
    }

    static func scope(for capability: Capability) -> ConsentScope? {
        ConsentScope.allCases.first { $0.dependentCapabilities.contains(capability) }
    }
}

// MARK: - Outgoing DTOs

/// EG-001. The bundled city-centre point, rounded to 4 decimals (~11 m): never a device location.
public struct WeatherForecastRequest: EgressPayload, Hashable {
    public static var egressClassification: DataClassification? { .localPrivate }

    public let cityCenterCoordinate: String

    public init(latitude: Double, longitude: Double) {
        cityCenterCoordinate = String(format: "%.4f,%.4f", locale: Locale(identifier: "en_US_POSIX"), latitude, longitude)
    }

    enum CodingKeys: String, CodingKey { case cityCenterCoordinate = "city_center_coordinate" }

    /// Reads the coordinate back from what the gate checked, so the transport sends exactly that.
    public static func coordinate(from authorized: AuthorizedEgress) -> (latitude: Double, longitude: Double)? {
        guard authorized.intent.purpose == .weatherForecast,
              let raw = authorized.fields[CodingKeys.cityCenterCoordinate.rawValue] else { return nil }
        let parts = raw.split(separator: ",")
        guard parts.count == 2, let lat = Double(parts[0]), let lon = Double(parts[1]),
              (-90...90).contains(lat), (-180...180).contains(lon) else { return nil }
        return (lat, lon)
    }
}

/// EG-003. A point on a street from the bundled catalogue (`FamousStreetCatalog`), rounded to 4
/// decimals: the same for everyone who picks that city, never a device location.
public struct StreetImageryRequest: EgressPayload, Hashable {
    public static var egressClassification: DataClassification? { .localPrivate }

    public let streetCoordinate: String

    public init(latitude: Double, longitude: Double) {
        streetCoordinate = String(format: "%.4f,%.4f", locale: Locale(identifier: "en_US_POSIX"), latitude, longitude)
    }

    enum CodingKeys: String, CodingKey { case streetCoordinate = "street_coordinate" }

    public static func coordinate(from authorized: AuthorizedEgress) -> (latitude: Double, longitude: Double)? {
        guard authorized.intent.purpose == .streetImagery,
              let raw = authorized.fields[CodingKeys.streetCoordinate.rawValue] else { return nil }
        let parts = raw.split(separator: ",")
        guard parts.count == 2, let lat = Double(parts[0]), let lon = Double(parts[1]),
              (-90...90).contains(lat), (-180...180).contains(lon) else { return nil }
        return (lat, lon)
    }
}

/// §112.2 example `ResolveProductRequest`. No route is registered for it yet (no licensed catalog API),
/// so the gate refuses it; it exists so the wire rules are tested before a partner is added.
public struct ProductLookupRequest: EgressPayload, Hashable {
    public static var egressClassification: DataClassification? { .publicProduct }

    public let gtin: String
    public let country: String
    public let locale: String

    public init(gtin: String, country: String, locale: String) {
        self.gtin = gtin
        self.country = country
        self.locale = locale
    }
}
