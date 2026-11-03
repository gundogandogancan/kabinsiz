import Foundation
@testable import ProductCapture
import Testing

/// SCAN-WP02: what a barcode says on its own, and where brand facts may come from.
@Suite("GS1 prefix and brand source gate")
struct GS1AndSourceTests {
    @Test("SCAN-T020 GS1 prefix names the issuing member organisation, not the maker")
    func prefixes() {
        #expect(GS1Prefix.kind(ofGTIN: "8682345678901") == .member("Türkiye"))
        #expect(GS1Prefix.kind(ofGTIN: "4006381333931") == .member("Almanya"))
        #expect(GS1Prefix.kind(ofGTIN: "036000291452") == .member("ABD"))      // UPC-A → GS1 US
        #expect(GS1Prefix.kind(ofGTIN: "9780306406157") == .book)
        #expect(GS1Prefix.kind(ofGTIN: "2112345678900") == .restrictedInStore)
        #expect(GS1Prefix.kind(ofGTIN: "84123") == .unknown)
        #expect(GS1Prefix.note(forGTIN: "8682345678901").contains("üretim yeri değildir"))
    }

    @Test("SCAN-T021 brand pages are not read unless the host is a licensed partner (V32-WEB-02..05)")
    func sourceGate() {
        #expect(BrandSourceGate.decide("https://www.example-brand.com/p/123") == .notLicensed)
        #expect(BrandSourceGate.decide("https://shop.partner.test/p/1", licensed: ["partner.test"]) == .partnerFeed(host: "shop.partner.test"))
        #expect(BrandSourceGate.decide("http://partner.test/p/1", licensed: ["partner.test"]) != .partnerFeed(host: "partner.test"))
        for bad in ["file:///etc/passwd", "javascript:alert(1)", "https://localhost/x", "https://192.168.1.4/p", "https://[::1]/p", "nonsense"] {
            if case .rejected = BrandSourceGate.decide(bad) {} else { Issue.record("not rejected: \(bad)") }
        }
        // No licensed host ships in this build.
        #expect(BrandSourceGate.licensedHosts.isEmpty)
    }

    @Test("SCAN-T022 the user's own web search carries only the code")
    func searchURL() throws {
        let url = try #require(BrandSourceGate.userSearchURL(forCode: "8682345678901"))
        #expect(url.absoluteString == "https://duckduckgo.com/?q=8682345678901")
        #expect(BrandSourceGate.userSearchURL(forCode: "<script>") == nil)
        #expect(BrandSourceGate.userSearchURL(forCode: "KB-JKT-01-NVY")?.query == "q=KB-JKT-01-NVY")
    }
}
