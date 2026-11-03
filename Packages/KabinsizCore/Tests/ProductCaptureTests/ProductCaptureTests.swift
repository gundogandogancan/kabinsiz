import CoreGraphics
import Foundation
@testable import ProductCapture
import ShoppingCopilot
import Testing
import Vision

/// SCAN-T001…T010: a product can be brought in by its barcode or by a photo of its label, read on this
/// device, matched only against the catalogue; never a "similar" product, never a link opened.
@Suite("Ürün fotoğrafı ve barkod (cihazda)")
struct ProductCaptureTests {
    let resolver = try! ProductResolver.syntheticCatalog()

    func read(_ image: CGImage?) async throws -> ProductPhotoResult {
        let image = try #require(image)
        return ProductCodeMatcher.match(try await ProductLabelReader.read(image), resolver: resolver)
    }

    // MARK: Real Vision on rendered labels

    @Test("SCAN-T001: a Code 128 barcode on a label resolves to exactly that variant, via the barcode")
    func code128Label() async throws {
        let result = try await read(SyntheticLabel.render(.code128("KB-JKT-01-NVY"), lines: ["KB-JKT-01-NVY", "ÖRNEK ETİKET · SENTETİK"]))
        guard case let .found(product, via) = result.match else { Issue.record("\(result.match)"); return }
        #expect(product.code == "KB-JKT-01-NVY")
        #expect(via == .barcode(symbology: "Code128"))
    }

    @Test("SCAN-T002: a label with only the printed code (no barcode) is read by on-device text recognition")
    func printedCodeOnly() async throws {
        let result = try await read(SyntheticLabel.render(.none, lines: ["KB-TEE-01-WHT", "Beden M · %100 pamuk"], rotation: 4))
        guard case let .found(product, via) = result.match else { Issue.record("\(result.match)"); return }
        #expect(product.code == "KB-TEE-01-WHT")
        #expect(via == .labelText)
    }

    @Test("SCAN-T003: a shop EAN-13 that is not in the catalogue stays not found; nothing similar is offered")
    func eanNotInCatalogue() async throws {
        let result = try await read(SyntheticLabel.render(.ean13("869000000001"), lines: []))
        guard case let .notInCatalog(codes) = result.match else { Issue.record("\(result.match)"); return }
        #expect(codes.first?.kind == .gtin)
        #expect(codes.first?.value == "8690000000012")
        #expect(codes.first?.source == .barcode(symbology: "EAN13"))
    }

    @Test("SCAN-T004 / V15-T-SEC-05: a link in a QR code is refused and counted, never resolved")
    func qrLinkRefused() async throws {
        let result = try await read(SyntheticLabel.render(.qr("https://kabinsiz-login.example/verify"), lines: []))
        #expect(result.match == .nothingRead)
        #expect(result.refusedPayloads == 1)
        #expect(result.codes.isEmpty)
    }

    @Test("SCAN-T005: a photo of the garment with no label reads nothing and says so")
    func plainGarment() async throws {
        let result = try await read(SyntheticLabel.plainGarment())
        #expect(result.match == .nothingRead)
    }

    @Test("SCAN-T006: photo data is decoded upright and downsampled; non-image data is refused")
    func decode() throws {
        let big = try #require(SyntheticLabel.render(.none, lines: ["KB-SNK-04-WHT"], width: 4000, height: 3000))
        let png = try #require(SyntheticLabel.png(big))
        let image = try #require(ProductLabelReader.image(from: png))
        #expect(max(image.width, image.height) == ProductLabelReader.maxPixelSize)
        #expect(ProductLabelReader.image(from: Data("not an image".utf8)) == nil)
    }

    @Test("SCAN-T006b: the CPU-only path reads the same label (used when Vision has no accelerator context)")
    func cpuOnly() throws {
        let image = try #require(SyntheticLabel.render(.code128("KB-SNK-04-WHT"), lines: ["KB-SNK-04-WHT"]))
        let codes = try ProductLabelReader.detectBarcodes(image, orientation: .up, cpuOnly: true)
        #expect(codes.first?.payload == "KB-SNK-04-WHT")
        let lines = try ProductLabelReader.recognizeText(image, orientation: .up, cpuOnly: true)
        #expect(lines.contains { $0.replacingOccurrences(of: " ", with: "").contains("KB-SNK-04-WHT") }, "\(lines)")
        // The classic detector used as the simulator fallback reads the same barcode.
        let classic = try ProductLabelReader.barcodes(image, orientation: .up, cpuOnly: true, revision: VNDetectBarcodesRequestRevision2)
        #expect(classic.first?.payload == "KB-SNK-04-WHT")
        let partial = ProductCodeMatcher.match(ProductLabelReading(barcodes: [.init(payload: "KB-SNK-04-WHT", symbology: "Code128")], unreadParts: [.text]),
                                               resolver: resolver)
        #expect(partial.unreadParts == [.text])
    }

    // MARK: Matching rules (pure)

    @Test("SCAN-T007: a model code with several colours asks which one; it never picks a colour")
    func modelCodeAsks() {
        let result = ProductCodeMatcher.match(ProductLabelReading(textLines: ["Model: KB-JKT-01"]), resolver: resolver)
        guard case let .choose(options) = result.match else { Issue.record("\(result.match)"); return }
        #expect(Set(options.map(\.code)) == ["KB-JKT-01-NVY", "KB-JKT-01-OLV"])
    }

    @Test("SCAN-T008: two different products on one photo are both offered, barcode first")
    func twoProducts() {
        let reading = ProductLabelReading(barcodes: [.init(payload: "KB-SNK-04-WHT", symbology: "Code128")],
                                          textLines: ["OB-DRS-01-RED"])
        guard case let .choose(options) = ProductCodeMatcher.match(reading, resolver: resolver).match else { Issue.record("expected choose"); return }
        #expect(options.map(\.code) == ["KB-SNK-04-WHT", "OB-DRS-01-RED"])
    }

    @Test("SCAN-T009: OCR digit slips are repaired only inside numeric segments of text, and only to a catalogue code")
    func ocrRepair() {
        // "O1" read for "01".
        let fixed = ProductCodeMatcher.match(ProductLabelReading(textLines: ["KB - TEE - O1 - WHT"]), resolver: resolver)
        guard case let .found(product, _) = fixed.match else { Issue.record("\(fixed.match)"); return }
        #expect(product.code == "KB-TEE-01-WHT")
        // A barcode is machine-read and is never "repaired".
        let barcode = ProductCodeMatcher.match(ProductLabelReading(barcodes: [.init(payload: "KB-TEE-O1-WHT", symbology: "Code128")]), resolver: resolver)
        guard case .notInCatalog = barcode.match else { Issue.record("\(barcode.match)"); return }
        // Letter segments are left alone: "WHT" is not turned into digits.
        #expect(ProductCodeMatcher.ocrRepairs("KB-TEE-01-WHT", source: .labelText).isEmpty)
    }

    @Test("SCAN-T010: GTIN check digits are enforced; words and prices are not product codes")
    func gtinAndNoise() {
        #expect(ProductCodeMatcher.gtin("8690000000012") == "8690000000012")
        #expect(ProductCodeMatcher.gtin("8690000000013") == nil)
        #expect(ProductCodeMatcher.gtin("96385074") == "96385074")
        for noise in ["M", "100%", "PAMUK", "349,90", "TL", "2026", "A-B", "WWW.EXAMPLE.COM"] {
            #expect(ProductCodeMatcher.productCode(noise) == nil, "\(noise)")
        }
        let reading = ProductLabelReading(textLines: ["Fiyat 349,90 TL", "Beden: M", "8 690000 000012"])
        let result = ProductCodeMatcher.match(reading, resolver: resolver)
        #expect(result.codes.map(\.value) == ["8690000000012"])
        guard case .notInCatalog = result.match else { Issue.record("\(result.match)"); return }
    }
}
