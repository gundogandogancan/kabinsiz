import CryptoKit
import DomainContracts
import FitPassport
import Foundation

// V37-06 (docs/audit/V37_SELF_MODEL_PROGRAM.md): a licensed partner catalogue feed. A partner signs the
// exact JSON bytes with Ed25519 and publishes the signature next to the feed. Nothing is decoded before
// the signature over those bytes checks out against the partner's pinned key, and every product must
// say where it came from and under which licence. Fetching is a plain GET of two public files: no user
// data, no cookies, no body. No partner contract exists yet → BLOCKED_EXTERNAL (contract + DPA first).

/// One partner, pinned. Built from a reviewed partner record, never from feed contents.
public struct PartnerFeedConfig: Sendable {
    /// Schema versions this build understands. Anything else is refused, not "best effort" decoded.
    public static let supportedSchemaVersions: Set<Int> = [1]
    /// Default byte cap for the feed: a few thousand variants fit in far less.
    public static let defaultMaxBytes = 2 * 1024 * 1024
    public static let maxProducts = 5_000

    public let partnerID: String
    public let feedURL: URL
    /// Detached signature: 64 raw bytes or their base64 text.
    public let signatureURL: URL
    /// Lower-case DNS names the feed and signature may come from. No wildcards.
    public let allowedHosts: Set<String>
    /// The partner's Ed25519 public key, pinned at contract time and shipped with the app.
    public let publicKey: Curve25519.Signing.PublicKey
    public let maxBytes: Int
    /// The oldest `issuedAt` accepted. A signed feed stays valid forever otherwise.
    public let maxFeedAge: TimeInterval
    public static let defaultMaxFeedAge: TimeInterval = 7 * 24 * 3600
    /// Clock difference tolerated for an `issuedAt` slightly in the future.
    public static let clockSkew: TimeInterval = 10 * 60

    public init(
        partnerID: String, feedURL: URL, signatureURL: URL, allowedHosts: Set<String>,
        publicKey: Curve25519.Signing.PublicKey, maxBytes: Int = PartnerFeedConfig.defaultMaxBytes,
        maxFeedAge: TimeInterval = PartnerFeedConfig.defaultMaxFeedAge
    ) {
        self.maxFeedAge = maxFeedAge
        self.partnerID = partnerID
        self.feedURL = feedURL
        self.signatureURL = signatureURL
        self.allowedHosts = allowedHosts
        self.publicKey = publicKey
        self.maxBytes = maxBytes
    }
}

/// Every way a feed is refused. Each one leaves the current local catalogue untouched.
public enum PartnerFeedError: Error, Hashable, Sendable {
    case insecureScheme
    case hostNotAllowed(String)
    /// Credentials, a port, a query or a fragment in the URL.
    case malformedURL
    /// The caller's capability check (CitadelGate `network.productOnly` in the app) said no.
    case notAuthorized
    case transportFailed
    case oversize(bytes: Int)
    case malformedSignature
    case signatureInvalid
    case unknownSchema(Int)
    case partnerMismatch
    case schemaInvalid(String)
    case missingProvenance(code: String)
    case missingLicence(code: String)
    case licenceNotForDisplay(code: String)
    case licenceExpired(code: String)
    case duplicateCode(String)
    /// `issuedAt` older than `maxFeedAge`: stale prices or a withdrawn licence must not come back.
    case stale(issuedAt: String)
    /// `issuedAt` later than now (beyond clock skew).
    case issuedInFuture(issuedAt: String)
    /// Not newer than the last accepted feed: a replayed, still validly signed old feed.
    case notNewer(issuedAt: String)
}

/// What the connector asks the transport for: two GETs, nothing else. Built only by the connector,
/// after the URL checks, so a transport never sees an unchecked URL.
public struct FeedFetchRequest: Hashable, Sendable {
    public let feedURL: URL
    public let signatureURL: URL
    public let maxBytes: Int

    fileprivate init(feedURL: URL, signatureURL: URL, maxBytes: Int) {
        self.feedURL = feedURL
        self.signatureURL = signatureURL
        self.maxBytes = maxBytes
    }
}

public struct FeedDownload: Sendable {
    public let payload: Data
    public let signature: Data

    public init(payload: Data, signature: Data) {
        self.payload = payload
        self.signature = signature
    }
}

/// How the feed bytes arrive. Tests use an in-memory transport; the app uses `EphemeralFeedTransport`.
public protocol FeedTransport: Sendable {
    func fetch(_ request: FeedFetchRequest) async throws -> FeedDownload
}

/// The partner's licence for one product, kept next to the product so the UI can say where it came from.
public struct PartnerLicence: Codable, Hashable, Sendable {
    public let licenceID: String
    /// The contract allows showing the product in the app.
    public let commercialDisplay: Bool
    /// `yyyy-MM-dd`, inclusive. Nil means the contract has no end date.
    public let expiresOn: String?
}

/// Where one product record came from at the partner.
public struct PartnerProvenance: Codable, Hashable, Sendable {
    public let partnerID: String
    public let sourceRecordID: String
}

/// A verified feed, mapped to the catalogue's own product type.
public struct PartnerFeedBatch: Sendable {
    public let partnerID: String
    public let schemaVersion: Int
    public let issuedAt: String
    /// `issuedAt` parsed; store it and pass it as `after` next time so an older feed is refused.
    public let issuedDate: Date
    public let products: [CatalogProduct]
    public let licences: [String: PartnerLicence]
    public let sources: [String: PartnerProvenance]
    /// SHA-256 of the exact signed bytes, for the evidence log.
    public let payloadSHA256: String

    public var resolver: ProductResolver { ProductResolver(products: products) }
}

public struct PartnerFeedConnector: Sendable {
    public let config: PartnerFeedConfig
    private let transport: any FeedTransport
    private let authorizeFetch: @Sendable () async throws -> Void
    private let today: @Sendable () -> Date

    /// - Parameter authorizeFetch: runs before any byte is requested. In the app it consumes a one-shot
    ///   `CitadelGate` grant for `.retailPrivacyGateway` / `.networkProductOnly`; ShoppingCopilot does
    ///   not depend on SystemContracts, so the gate is injected rather than imported.
    public init(
        config: PartnerFeedConfig, transport: any FeedTransport,
        authorizeFetch: @escaping @Sendable () async throws -> Void, today: @escaping @Sendable () -> Date = Date.init
    ) {
        self.config = config
        self.transport = transport
        self.authorizeFetch = authorizeFetch
        self.today = today
    }

    /// URL checks → capability check → GET both files → verify. Fails closed at every step.
    /// - Parameter previous: `issuedDate` of the last accepted batch; a feed not newer than it is refused.
    public func fetch(after previous: Date? = nil) async throws(PartnerFeedError) -> PartnerFeedBatch {
        try Self.checkURL(config.feedURL, allowedHosts: config.allowedHosts)
        try Self.checkURL(config.signatureURL, allowedHosts: config.allowedHosts)
        do { try await authorizeFetch() } catch { throw .notAuthorized }
        let request = FeedFetchRequest(feedURL: config.feedURL, signatureURL: config.signatureURL, maxBytes: config.maxBytes)
        let download: FeedDownload
        do { download = try await transport.fetch(request) } catch let error as PartnerFeedError {
            throw error
        } catch {
            throw .transportFailed
        }
        return try verify(payload: download.payload, signature: download.signature, after: previous)
    }

    /// Pure check of bytes already in hand. Order matters: size, then signature over the exact bytes,
    /// and only then JSON. An unsigned or altered payload is never parsed.
    public func verify(payload: Data, signature: Data, after previous: Date? = nil) throws(PartnerFeedError) -> PartnerFeedBatch {
        guard payload.count <= config.maxBytes else { throw .oversize(bytes: payload.count) }
        guard signature.count <= 256 else { throw .malformedSignature }
        let raw = try Self.signatureBytes(signature)
        guard config.publicKey.isValidSignature(raw, for: payload) else { throw .signatureInvalid }
        return try decode(payload, after: previous)
    }

    // MARK: URL rules

    static func checkURL(_ url: URL, allowedHosts: Set<String>) throws(PartnerFeedError) {
        guard let parts = URLComponents(url: url, resolvingAgainstBaseURL: false) else { throw .malformedURL }
        guard parts.scheme?.lowercased() == "https" else { throw .insecureScheme }
        guard parts.user == nil, parts.password == nil, parts.port == nil || parts.port == 443,
              parts.query == nil, parts.fragment == nil, !parts.path.contains("..")
        else { throw .malformedURL }
        guard let host = parts.host, !host.isEmpty else { throw .malformedURL }
        // Exact, case-sensitive match against lower-case entries: `EXAMPLE.com` or `example.com.` is refused.
        guard allowedHosts.contains(host) else { throw .hostNotAllowed(host) }
    }

    static func signatureBytes(_ data: Data) throws(PartnerFeedError) -> Data {
        if data.count == 64 { return data }
        guard let text = String(data: data, encoding: .ascii)?.trimmingCharacters(in: .whitespacesAndNewlines),
              let decoded = Data(base64Encoded: text), decoded.count == 64
        else { throw .malformedSignature }
        return decoded
    }

    // MARK: Schema

    static let envelopeKeys: Set<String> = ["schemaVersion", "partnerID", "issuedAt", "products"]
    static let provenanceKeys: Set<String> = ["partnerID", "sourceRecordID"]
    static let licenceKeys: Set<String> = ["licenceID", "commercialDisplay", "expiresOn"]
    static let sizeRowKeys: Set<String> = ["size", "chestCm", "waistCm"]
    static let productKeys: Set<String> = [
        "code", "modelCode", "brandID", "brandName", "name", "category", "colorName", "isNeutralColor",
        "formalityLow", "formalityHigh", "catalogRevision", "sizeChart", "materialClaims", "isSponsored",
        "provenance", "licence",
    ]
    static let maxTextLength = 120

    struct Envelope: Decodable {
        let schemaVersion: Int
        let partnerID: String
        let issuedAt: String
        let products: [FeedProduct]
    }

    struct FeedSizeRow: Decodable {
        let size: String
        let chestCm: ClosedRange<Double>?
        let waistCm: ClosedRange<Double>?
    }

    struct FeedProduct: Decodable {
        let code: String
        let modelCode: String
        let brandID: String
        let brandName: String
        let name: String
        let category: GarmentCategory
        let colorName: String
        let isNeutralColor: Bool
        let formalityLow: Formality
        let formalityHigh: Formality
        let catalogRevision: Int
        let sizeChart: [FeedSizeRow]?
        let materialClaims: [MaterialClaim.Property]
        let isSponsored: Bool
        let provenance: PartnerProvenance?
        let licence: PartnerLicence?
    }

    private func decode(_ payload: Data, after previous: Date?) throws(PartnerFeedError) -> PartnerFeedBatch {
        // Signed is not the same as well-formed: unknown keys are refused, so a field the app does not
        // understand (a tracking URL, a "price") cannot ride along unnoticed.
        guard let object = try? JSONSerialization.jsonObject(with: payload) as? [String: Any] else { throw .schemaInvalid("not an object") }
        guard let version = object["schemaVersion"] as? Int else { throw .schemaInvalid("schemaVersion") }
        guard PartnerFeedConfig.supportedSchemaVersions.contains(version) else { throw .unknownSchema(version) }
        guard Set(object.keys) == Self.envelopeKeys else { throw .schemaInvalid("envelope keys") }
        guard let rawProducts = object["products"] as? [[String: Any]] else { throw .schemaInvalid("products") }
        for raw in rawProducts {
            guard Set(raw.keys).isSubset(of: Self.productKeys) else { throw .schemaInvalid("unknown product key") }
            // The same rule one level down: provenance, licence and size rows.
            for (key, allowed) in [("provenance", Self.provenanceKeys), ("licence", Self.licenceKeys)] {
                if let nested = raw[key] as? [String: Any], !Set(nested.keys).isSubset(of: allowed) { throw .schemaInvalid("unknown \(key) key") }
            }
            if let rows = raw["sizeChart"] as? [[String: Any]], rows.contains(where: { !Set($0.keys).isSubset(of: Self.sizeRowKeys) }) {
                throw .schemaInvalid("unknown size row key")
            }
        }
        let envelope: Envelope
        do { envelope = try JSONDecoder().decode(Envelope.self, from: payload) } catch { throw .schemaInvalid("decode") }
        guard envelope.partnerID == config.partnerID else { throw .partnerMismatch }
        guard envelope.issuedAt.count <= 40, let issued = Self.instant(envelope.issuedAt) else { throw .schemaInvalid("issuedAt") }
        let now = today()
        guard issued.timeIntervalSince(now) <= PartnerFeedConfig.clockSkew else { throw .issuedInFuture(issuedAt: envelope.issuedAt) }
        guard now.timeIntervalSince(issued) <= config.maxFeedAge else { throw .stale(issuedAt: envelope.issuedAt) }
        if let previous, issued <= previous { throw .notNewer(issuedAt: envelope.issuedAt) }
        guard !envelope.products.isEmpty, envelope.products.count <= PartnerFeedConfig.maxProducts else { throw .schemaInvalid("product count") }

        let todayText = Self.dayString(now)
        var seen: Set<String> = []
        var products: [CatalogProduct] = []
        var licences: [String: PartnerLicence] = [:]
        var sources: [String: PartnerProvenance] = [:]
        for item in envelope.products {
            guard ProductResolver.normalize(item.code) == item.code, ProductResolver.normalize(item.modelCode) == item.modelCode
            else { throw .schemaInvalid("code") }
            guard seen.insert(item.code).inserted else { throw .duplicateCode(item.code) }
            for text in [item.brandID, item.brandName, item.name, item.colorName] where !Self.isPlainText(text) {
                throw .schemaInvalid("text field")
            }
            guard item.formalityLow <= item.formalityHigh, item.catalogRevision >= 1 else { throw .schemaInvalid("range") }
            guard let source = item.provenance, source.partnerID == config.partnerID, Self.isPlainText(source.sourceRecordID)
            else { throw .missingProvenance(code: item.code) }
            guard let licence = item.licence, Self.isPlainText(licence.licenceID) else { throw .missingLicence(code: item.code) }
            guard licence.commercialDisplay else { throw .licenceNotForDisplay(code: item.code) }
            if let end = licence.expiresOn {
                guard Self.isDay(end) else { throw .missingLicence(code: item.code) }
                // ISO days compare correctly as text.
                guard end >= todayText else { throw .licenceExpired(code: item.code) }
            }
            let chart = try item.sizeChart.map { rows throws(PartnerFeedError) -> SizeChart in
                for row in rows where !Self.isPlainText(row.size) { throw .schemaInvalid("size") }
                return SizeChart(revision: item.catalogRevision,
                                 rows: rows.map { SizeChart.Row(size: $0.size, chestCm: $0.chestCm, waistCm: $0.waistCm) },
                                 provenance: .licensedCatalog)
            }
            // Every fact from the feed is labelled as licensed partner data; the feed cannot claim
            // to be synthetic, user-entered or anything else.
            products.append(CatalogProduct(
                code: item.code, modelCode: item.modelCode, brandID: item.brandID, brandName: item.brandName,
                name: item.name, category: item.category, colorName: item.colorName, isNeutralColor: item.isNeutralColor,
                formalityLow: item.formalityLow, formalityHigh: item.formalityHigh, catalogRevision: item.catalogRevision,
                sizeChart: chart, materialClaims: item.materialClaims.map { MaterialClaim(property: $0, source: .licensedCatalog) },
                isSponsored: item.isSponsored, provenance: .licensedCatalog))
            licences[item.code] = licence
            sources[item.code] = source
        }
        let digest = SHA256.hash(data: payload).map { String(format: "%02x", $0) }.joined()
        return PartnerFeedBatch(partnerID: envelope.partnerID, schemaVersion: envelope.schemaVersion, issuedAt: envelope.issuedAt,
                                issuedDate: issued, products: products, licences: licences, sources: sources, payloadSHA256: digest)
    }

    /// Short text with no control characters and nothing that looks like a link. Catalogue text is shown,
    /// never executed or opened.
    static func isPlainText(_ text: String) -> Bool {
        guard !text.isEmpty, text.count <= maxTextLength else { return false }
        let lowered = text.lowercased()
        guard !lowered.contains("://"), !lowered.contains("www.") else { return false }
        return !text.unicodeScalars.contains { CharacterSet.controlCharacters.contains($0) }
    }

    /// `yyyy-MM-dd` naming a real calendar day (no `9999-99-99`), years 2000–2100.
    static func isDay(_ text: String) -> Bool {
        let parts = text.split(separator: "-", omittingEmptySubsequences: false)
        guard parts.count == 3, parts[0].count == 4, parts[1].count == 2, parts[2].count == 2,
              parts.allSatisfy({ $0.allSatisfy(\.isASCII) && $0.allSatisfy(\.isNumber) }),
              let y = Int(parts[0]), let m = Int(parts[1]), let d = Int(parts[2]), (2000 ... 2100).contains(y)
        else { return false }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        guard let date = calendar.date(from: DateComponents(year: y, month: m, day: d)) else { return false }
        return dayString(date) == text
    }

    /// RFC 3339 / ISO 8601 instant with a zone (`2026-11-05T00:00:00Z`), optionally with fractions.
    static func instant(_ text: String) -> Date? {
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        if let date = plain.date(from: text) { return date }
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return fractional.date(from: text)
    }

    static func dayString(_ date: Date) -> String {
        let c = Calendar(identifier: .gregorian).dateComponents(in: TimeZone(identifier: "UTC")!, from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }
}
