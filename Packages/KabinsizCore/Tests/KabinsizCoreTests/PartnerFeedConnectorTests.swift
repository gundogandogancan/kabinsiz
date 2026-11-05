import CryptoKit
import DomainContracts
import Foundation
import Testing
@testable import ShoppingCopilot

/// In-memory transport: records what was asked for and hands back fixed bytes.
final class PartnerFeedMemoryTransport: FeedTransport, @unchecked Sendable {
    private let lock = NSLock()
    private var _requests: [FeedFetchRequest] = []
    let download: FeedDownload

    init(_ download: FeedDownload) { self.download = download }

    var requests: [FeedFetchRequest] { lock.withLock { _requests } }

    func fetch(_ request: FeedFetchRequest) async throws -> FeedDownload {
        lock.withLock { _requests.append(request) }
        return download
    }
}

@Suite("V37-06 partner feed connector: signed, allowlisted, licensed or nothing")
struct PartnerFeedConnectorTests {
    static let host = "feed.partner.example"
    let partnerKey = Curve25519.Signing.PrivateKey()
    /// A fixed day inside every licence window used below.
    let today: @Sendable () -> Date = { Date(timeIntervalSince1970: 1_793_836_800) } // 2026-11-05 UTC

    func config(
        key: Curve25519.Signing.PublicKey? = nil, feed: String = "https://\(host)/v1/feed.json",
        signature: String = "https://\(host)/v1/feed.json.sig", maxBytes: Int = PartnerFeedConfig.defaultMaxBytes
    ) -> PartnerFeedConfig {
        PartnerFeedConfig(partnerID: "ornek-partner", feedURL: URL(string: feed)!, signatureURL: URL(string: signature)!,
                          allowedHosts: [Self.host], publicKey: key ?? partnerKey.publicKey, maxBytes: maxBytes)
    }

    static func product(code: String = "PT-SHIRT-01-BLU", licence: String? = #"{"licenceID":"LIC-2026-001","commercialDisplay":true,"expiresOn":"2027-12-31"}"#,
                        provenance: String? = #"{"partnerID":"ornek-partner","sourceRecordID":"rec-1"}"#) -> String {
        var fields = [
            #""code":"\#(code)""#, #""modelCode":"PT-SHIRT-01""#, #""brandID":"ornek-partner""#, #""brandName":"Örnek Ortak""#,
            #""name":"Poplin gömlek""#, #""category":"top""#, #""colorName":"mavi""#, #""isNeutralColor":false"#,
            #""formalityLow":1"#, #""formalityHigh":2"#, #""catalogRevision":3"#,
            #""sizeChart":[{"size":"M","chestCm":[94,102],"waistCm":null}]"#, #""materialClaims":["breathable"]"#, #""isSponsored":false"#,
        ]
        if let licence { fields.append(#""licence":\#(licence)"#) }
        if let provenance { fields.append(#""provenance":\#(provenance)"#) }
        return "{" + fields.joined(separator: ",") + "}"
    }

    static func feed(schema: Int = 1, products: [String] = [product()], issuedAt: String = "2026-11-05T00:00:00Z") -> Data {
        Data(#"{"schemaVersion":\#(schema),"partnerID":"ornek-partner","issuedAt":"\#(issuedAt)","products":[\#(products.joined(separator: ","))]}"#.utf8)
    }

    func signed(_ payload: Data, with key: Curve25519.Signing.PrivateKey? = nil) throws -> FeedDownload {
        FeedDownload(payload: payload, signature: try (key ?? partnerKey).signature(for: payload))
    }

    func connector(_ config: PartnerFeedConfig, _ transport: PartnerFeedMemoryTransport,
                   authorize: @escaping @Sendable () async throws -> Void = {}) -> PartnerFeedConnector {
        PartnerFeedConnector(config: config, transport: transport, authorizeFetch: authorize, today: today)
    }

    @Test("V37-06-T01 a signed, licensed feed from an allowlisted HTTPS host maps to catalogue products")
    func validFeed() async throws {
        let transport = PartnerFeedMemoryTransport(try signed(Self.feed()))
        let batch = try await connector(config(), transport).fetch()
        #expect(batch.products.count == 1)
        let p = try #require(batch.products.first)
        #expect(p.code == "PT-SHIRT-01-BLU" && p.category == .top && p.brandName == "Örnek Ortak")
        #expect(p.provenance == .licensedCatalog)
        #expect(p.sizeChart?.provenance == .licensedCatalog && p.sizeChart?.rows.first?.chestCm == 94...102)
        #expect(p.materialClaims == [MaterialClaim(property: .breathable, source: .licensedCatalog)])
        #expect(batch.licences["PT-SHIRT-01-BLU"]?.licenceID == "LIC-2026-001")
        #expect(batch.sources["PT-SHIRT-01-BLU"]?.sourceRecordID == "rec-1")
        #expect(batch.payloadSHA256.count == 64)
        #expect(batch.resolver.resolve("pt-shirt-01") == .found(p))
        // The transport was asked for exactly the two checked URLs and nothing else.
        #expect(transport.requests.map(\.feedURL.absoluteString) == ["https://\(Self.host)/v1/feed.json"])
        #expect(transport.requests.map(\.signatureURL.absoluteString) == ["https://\(Self.host)/v1/feed.json.sig"])
    }

    @Test("V37-06-T02 a base64 text signature is accepted too")
    func base64Signature() throws {
        let payload = Self.feed()
        let sig = try partnerKey.signature(for: payload).base64EncodedString() + "\n"
        let batch = try connector(config(), PartnerFeedMemoryTransport(try signed(payload))).verify(payload: payload, signature: Data(sig.utf8))
        #expect(batch.products.count == 1)
    }

    @Test("V37-06-T03 one flipped byte anywhere in the payload is refused before parsing")
    func tamperedByte() throws {
        let original = Self.feed()
        let download = try signed(original)
        let c = connector(config(), PartnerFeedMemoryTransport(download))
        for index in [0, original.count / 2, original.count - 1] {
            var tampered = original
            tampered[index] ^= 0x01
            #expect(throws: PartnerFeedError.signatureInvalid) { try c.verify(payload: tampered, signature: download.signature) }
        }
        var badSig = download.signature
        badSig[0] ^= 0x01
        #expect(throws: PartnerFeedError.signatureInvalid) { try c.verify(payload: original, signature: badSig) }
    }

    @Test("V37-06-T04 a feed signed by another key is refused")
    func wrongKey() async throws {
        let impostor = Curve25519.Signing.PrivateKey()
        let transport = PartnerFeedMemoryTransport(try signed(Self.feed(), with: impostor))
        await #expect(throws: PartnerFeedError.signatureInvalid) { try await connector(config(), transport).fetch() }
        // And a pinned key that is not the partner's refuses the partner's real signature.
        let other = PartnerFeedMemoryTransport(try signed(Self.feed()))
        await #expect(throws: PartnerFeedError.signatureInvalid) { try await connector(config(key: impostor.publicKey), other).fetch() }
    }

    @Test("V37-06-T05 a host outside the allowlist is refused before any request", arguments: [
        "https://evil.example/v1/feed.json", "https://FEED.partner.example/v1/feed.json", "https://feed.partner.example.evil.example/f.json",
        "https://feed.partner.example./v1/feed.json",
    ])
    func hostNotAllowlisted(url: String) async throws {
        let transport = PartnerFeedMemoryTransport(try signed(Self.feed()))
        await #expect(throws: PartnerFeedError.self) { try await connector(config(feed: url), transport).fetch() }
        #expect(transport.requests.isEmpty)
    }

    @Test("V37-06-T06 plain HTTP is refused before any request")
    func plainHTTP() async throws {
        let transport = PartnerFeedMemoryTransport(try signed(Self.feed()))
        await #expect(throws: PartnerFeedError.insecureScheme) {
            try await connector(config(feed: "http://\(Self.host)/v1/feed.json"), transport).fetch()
        }
        await #expect(throws: PartnerFeedError.insecureScheme) {
            try await connector(config(signature: "http://\(Self.host)/v1/feed.json.sig"), transport).fetch()
        }
        #expect(transport.requests.isEmpty)
    }

    @Test("V37-06-T07 credentials, ports, queries and fragments in the URL are refused", arguments: [
        "https://user:pw@feed.partner.example/f.json", "https://feed.partner.example:8443/f.json",
        "https://feed.partner.example/f.json?uid=1", "https://feed.partner.example/f.json#x",
    ])
    func malformedURL(url: String) async throws {
        let transport = PartnerFeedMemoryTransport(try signed(Self.feed()))
        await #expect(throws: PartnerFeedError.malformedURL) { try await connector(config(feed: url), transport).fetch() }
        #expect(transport.requests.isEmpty)
    }

    @Test("V37-06-T08 a payload over the byte cap is refused, even with a valid signature")
    func oversize() async throws {
        let payload = Self.feed()
        let transport = PartnerFeedMemoryTransport(try signed(payload))
        await #expect(throws: PartnerFeedError.oversize(bytes: payload.count)) {
            try await connector(config(maxBytes: payload.count - 1), transport).fetch()
        }
    }

    @Test("V37-06-T09 a validly signed feed with an unknown schema version is refused")
    func unknownSchema() async throws {
        let transport = PartnerFeedMemoryTransport(try signed(Self.feed(schema: 2)))
        await #expect(throws: PartnerFeedError.unknownSchema(2)) { try await connector(config(), transport).fetch() }
    }

    @Test("V37-06-T10 every product must carry provenance and a displayable, unexpired licence")
    func provenanceAndLicence() throws {
        let c = connector(config(), PartnerFeedMemoryTransport(FeedDownload(payload: Data(), signature: Data())))
        func check(_ product: String, _ expected: PartnerFeedError) throws {
            let payload = Self.feed(products: [product])
            #expect(throws: expected) { try c.verify(payload: payload, signature: try partnerKey.signature(for: payload)) }
        }
        try check(Self.product(licence: nil), .missingLicence(code: "PT-SHIRT-01-BLU"))
        try check(Self.product(provenance: nil), .missingProvenance(code: "PT-SHIRT-01-BLU"))
        try check(Self.product(provenance: #"{"partnerID":"someone-else","sourceRecordID":"rec-1"}"#), .missingProvenance(code: "PT-SHIRT-01-BLU"))
        try check(Self.product(licence: #"{"licenceID":"L","commercialDisplay":false,"expiresOn":null}"#), .licenceNotForDisplay(code: "PT-SHIRT-01-BLU"))
        try check(Self.product(licence: #"{"licenceID":"L","commercialDisplay":true,"expiresOn":"2026-11-04"}"#), .licenceExpired(code: "PT-SHIRT-01-BLU"))
    }

    @Test("V37-06-T11 signed but odd content is still refused: unknown keys, links, duplicates, other partner")
    func signedButInvalid() throws {
        let c = connector(config(), PartnerFeedMemoryTransport(FeedDownload(payload: Data(), signature: Data())))
        func check(_ payload: Data, _ expected: PartnerFeedError) throws {
            #expect(throws: expected) { try c.verify(payload: payload, signature: try partnerKey.signature(for: payload)) }
        }
        let withPrice = Self.product().replacingOccurrences(of: #""isSponsored":false"#, with: #""isSponsored":false,"trackingURL":"x""#)
        try check(Self.feed(products: [withPrice]), .schemaInvalid("unknown product key"))
        let withLink = Self.product().replacingOccurrences(of: "Poplin gömlek", with: "https://evil.example")
        try check(Self.feed(products: [withLink]), .schemaInvalid("text field"))
        try check(Self.feed(products: [Self.product(), Self.product()]), .duplicateCode("PT-SHIRT-01-BLU"))
        let otherPartner = Data(String(decoding: Self.feed(), as: UTF8.self)
            .replacingOccurrences(of: #""partnerID":"ornek-partner","issuedAt""#, with: #""partnerID":"other","issuedAt""#).utf8)
        try check(otherPartner, .partnerMismatch)
    }

    @Test("V37-06-T12 no request leaves when the capability check refuses")
    func capabilityDenied() async throws {
        struct Denied: Error {}
        let transport = PartnerFeedMemoryTransport(try signed(Self.feed()))
        await #expect(throws: PartnerFeedError.notAuthorized) {
            try await connector(config(), transport, authorize: { throw Denied() }).fetch()
        }
        #expect(transport.requests.isEmpty)
    }

    @Test("V37-06-T13 an old, a future or a replayed feed is refused even with a valid signature")
    func freshness() throws {
        let c = connector(config(), PartnerFeedMemoryTransport(try signed(Self.feed())))
        func verify(_ issuedAt: String, after previous: Date? = nil) throws -> PartnerFeedBatch {
            let d = try signed(Self.feed(issuedAt: issuedAt))
            return try c.verify(payload: d.payload, signature: d.signature, after: previous)
        }
        #expect(throws: PartnerFeedError.stale(issuedAt: "2026-10-01T00:00:00Z")) { try verify("2026-10-01T00:00:00Z") }
        #expect(throws: PartnerFeedError.issuedInFuture(issuedAt: "2026-11-06T00:00:00Z")) { try verify("2026-11-06T00:00:00Z") }
        #expect(throws: PartnerFeedError.schemaInvalid("issuedAt")) { try verify("yesterday") }
        let first = try verify("2026-11-04T12:00:00Z")
        #expect(first.issuedDate == Date(timeIntervalSince1970: 1_793_793_600))
        // The same feed again, or an older one, after it was accepted: a replay.
        #expect(throws: PartnerFeedError.notNewer(issuedAt: "2026-11-04T12:00:00Z")) { try verify("2026-11-04T12:00:00Z", after: first.issuedDate) }
        #expect(throws: PartnerFeedError.notNewer(issuedAt: "2026-11-04T06:00:00.5Z")) { try verify("2026-11-04T06:00:00.5Z", after: first.issuedDate) }
        #expect(try verify("2026-11-04T23:00:00Z", after: first.issuedDate).products.count == 1)
    }

    @Test("V37-06-T14 unknown keys one level down and impossible days are refused")
    func nestedKeysAndDays() throws {
        let c = connector(config(), PartnerFeedMemoryTransport(try signed(Self.feed())))
        func verify(_ product: String) throws {
            let d = try signed(Self.feed(products: [product]))
            _ = try c.verify(payload: d.payload, signature: d.signature)
        }
        #expect(throws: PartnerFeedError.schemaInvalid("unknown licence key")) {
            try verify(Self.product(licence: #"{"licenceID":"L","commercialDisplay":true,"expiresOn":null,"trackingURL":"x"}"#))
        }
        #expect(throws: PartnerFeedError.schemaInvalid("unknown provenance key")) {
            try verify(Self.product(provenance: #"{"partnerID":"ornek-partner","sourceRecordID":"r","price":9}"#))
        }
        #expect(throws: PartnerFeedError.missingLicence(code: "PT-SHIRT-01-BLU")) {
            try verify(Self.product(licence: #"{"licenceID":"L","commercialDisplay":true,"expiresOn":"9999-99-99"}"#))
        }
        #expect(throws: PartnerFeedError.missingLicence(code: "PT-SHIRT-01-BLU")) {
            try verify(Self.product(licence: #"{"licenceID":"L","commercialDisplay":true,"expiresOn":"2027-02-30"}"#))
        }
        #expect(PartnerFeedConnector.isDay("2028-02-29") && !PartnerFeedConnector.isDay("2027-02-29"))
    }
}
