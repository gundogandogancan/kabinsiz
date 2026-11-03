import Foundation

/// Everything a request must declare before it may leave the device (§112.2). This type checks the
/// declaration itself; the runtime gate that enforces allowlists and consent is WP15-03.
public struct EgressIntent: VersionedContract, Hashable {
    public static var currentSchemaVersion: Int { 1 }
    public static var knownKeys: Set<String> { Set(CodingKeys.allCases.map(\.stringValue)) }

    public enum Method: String, Codable, Sendable { case get = "GET", post = "POST" }

    public enum Purpose: String, Codable, CaseIterable, Sendable {
        case productLookup = "PRODUCT_LOOKUP"
        case weatherForecast = "WEATHER_FORECAST"
        /// Street-level imagery of a catalogue street behind the figure (Apple Look Around).
        case streetImagery = "STREET_IMAGERY"
    }

    public enum ConsentBasis: String, Codable, Sendable {
        /// The user just did something that names this destination and data (scan, "update weather").
        case explicitUserAction = "EXPLICIT_USER_ACTION"
        case none = "NONE"
    }

    public enum Retention: String, Codable, Sendable {
        case none = "NONE", session = "SESSION", cacheWithTTL = "CACHE_TTL"
    }

    public var schemaVersion: Int
    public var destinationHost: String
    public var method: Method
    public var endpointPath: String
    public var classification: DataClassification
    public var purpose: Purpose
    /// Names of the fields sent, e.g. `["gtin", "country", "locale"]`. Values are never part of the intent.
    public var fields: [String]
    public var consentBasis: ConsentBasis
    public var userVisibleEffect: String
    public var retention: Retention
    public var requiresTLS: Bool

    public init(
        destinationHost: String, method: Method, endpointPath: String, classification: DataClassification, purpose: Purpose,
        fields: [String], consentBasis: ConsentBasis, userVisibleEffect: String, retention: Retention, requiresTLS: Bool = true
    ) {
        self.schemaVersion = Self.currentSchemaVersion
        self.destinationHost = destinationHost
        self.method = method
        self.endpointPath = endpointPath
        self.classification = classification
        self.purpose = purpose
        self.fields = fields
        self.consentBasis = consentBasis
        self.userVisibleEffect = userVisibleEffect
        self.retention = retention
        self.requiresTLS = requiresTLS
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion = "schema_version", destinationHost = "destination_host", method
        case endpointPath = "endpoint_path", classification, purpose, fields, consentBasis = "consent_basis"
        case userVisibleEffect = "user_visible_effect", retention, requiresTLS = "requires_tls"
    }

    /// The only field names each purpose may send. An allowlist, not a blocklist: anything unlisted
    /// (`lat`, `address`, `size_cm`, a Turkish-İ spelling of a blocked word) is refused by construction.
    public static let allowedFields: [Purpose: Set<String>] = [
        .productLookup: ["gtin", "model_code", "country", "locale"],
        .weatherForecast: ["city_center_coordinate"],
        .streetImagery: ["street_coordinate"],
    ]

    /// Which data class each purpose carries. Product lookups are public facts; a weather request reveals
    /// the trip destination, so it is private and needs the explicit tap.
    public static let classificationForPurpose: [Purpose: DataClassification] = [
        .productLookup: .publicProduct,
        .weatherForecast: .localPrivate,
        // A catalogue point says which city the person looks at: private, explicit tap only (EG-003).
        .streetImagery: .localPrivate,
    ]

    public func validate() throws(FaultCode) {
        guard schemaVersion == Self.currentSchemaVersion,
              Self.isValidHost(destinationHost),
              endpointPath.hasPrefix("/"), !endpointPath.contains("?"), !endpointPath.contains("#"),
              !endpointPath.contains(".."), !endpointPath.contains(" "),
              !fields.isEmpty, Set(fields).count == fields.count,
              fields.allSatisfy(Self.isPlainFieldName),
              !userVisibleEffect.isEmpty, requiresTLS
        else { throw .schemaInvalid }
        // INV-01: nothing leaves without a user action that names destination and data.
        guard consentBasis == .explicitUserAction,
              Self.classificationForPurpose[purpose] == classification,
              let allowed = Self.allowedFields[purpose], Set(fields).isSubset(of: allowed)
        else { throw .egressBlocked }
    }

    /// Lower-case DNS name with at least one dot: no scheme, port, path, spaces or IP-literal tricks.
    static func isValidHost(_ host: String) -> Bool {
        let labels = host.split(separator: ".", omittingEmptySubsequences: false)
        guard labels.count >= 2, host.count <= 253 else { return false }
        return labels.allSatisfy { label in
            guard let first = label.first, let last = label.last, label.count <= 63, first != "-", last != "-" else { return false }
            return label.allSatisfy { $0.isASCII && ($0.isLowercase || $0.isNumber || $0 == "-") }
        }
    }

    static func isPlainFieldName(_ name: String) -> Bool {
        !name.isEmpty && name.allSatisfy { $0.isASCII && ($0.isLowercase || $0.isNumber || $0 == "_") }
    }
}
