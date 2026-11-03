import XCTest

/// SCAN-T011…T015 on the simulator (SIMULATOR_ONLY). No real label can be photographed there, so each launch renders
/// a synthetic label on the device (`-productPhotoFixture`) and sends it through the same on-device
/// Vision reader a real photo goes through; the screen marks it as an example. Live scanning and the
/// camera itself need a real iPhone (REAL_DEVICE_BLOCKED).
final class ProductPhotoUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    private func openIntake(_ fixture: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest", "-productPhotoFixture", fixture]
        app.launch()
        app.tab("Dene")
        let photo = app.buttons["tryOnPhoto"]
        XCTAssertTrue(photo.waitForExistence(timeout: 8))
        XCTAssertTrue(photo.isEnabled, "photo intake is available, not 'bu sürümde yok'")
        photo.tap()
        XCTAssertTrue(app.buttons["scanPickPhoto"].waitForExistence(timeout: 5), "a photo can be chosen")
        XCTAssertTrue(app.textFields["productCodeField"].exists, "typing the code is still there")
        return app
    }

    func testBarcodeOnLabelPhotoFindsTheProduct() {
        let app = openIntake("code128")
        // The simulator has no live barcode scanner (VisionKit): that button is disabled and the screen says why.
        // (The iOS 26 simulator does report a camera, so "Fotoğraf çek" stays enabled.)
        XCTAssertFalse(app.buttons["scanLiveBarcode"].isEnabled)
        XCTAssertTrue(app.staticTexts["scanCameraNote"].exists)
        let source = app.staticTexts["photoReadSource"]
        let failed = app.descendants(matching: .any)["photoDebugError"]
        XCTAssertTrue(source.waitForExistence(timeout: 20), "the label was read; reader error: \(failed.exists ? failed.label : "none")")
        XCTAssertTrue(source.label.contains("barkoddan (Code128)"), source.label)
        XCTAssertTrue(source.label.contains("KB-JKT-01-NVY"), source.label)
        XCTAssertTrue(app.otherElements["decisionCard"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["photoExample"].exists, "a fixture is marked as an example")
        attach(app, "SCAN-photo-barcode-found")
    }

    func testPrintedCodeIsReadFromTheLabelText() {
        let app = openIntake("text")
        let source = app.staticTexts["photoReadSource"]
        XCTAssertTrue(source.waitForExistence(timeout: 20))
        XCTAssertTrue(source.label.contains("Etiketteki yazıdan"), source.label)
        XCTAssertTrue(source.label.contains("KB-TEE-01-WHT"), source.label)
        XCTAssertTrue(app.otherElements["decisionCard"].waitForExistence(timeout: 5))
        attach(app, "SCAN-photo-text-found")
    }

    func testShopBarcodeNotInCatalogueIsSaidPlainly() {
        let app = openIntake("ean")
        XCTAssertTrue(app.otherElements["photoNotInCatalog"].waitForExistence(timeout: 20))
        XCTAssertTrue(app.staticTexts["8690000000012 · GTIN/EAN barkod numarası, barkoddan"].exists)
        XCTAssertFalse(app.otherElements["decisionCard"].exists, "no similar product is shown instead")
        attach(app, "SCAN-photo-ean-not-in-catalogue")
    }

    func testLinkInQRIsRefusedAndAPlainPhotoSaysNothingWasRead() {
        var app = openIntake("qr")
        XCTAssertTrue(app.otherElements["photoNothingRead"].waitForExistence(timeout: 20))
        XCTAssertTrue(app.staticTexts["photoRefusedLink"].exists, "the link is mentioned, not opened")
        attach(app, "SCAN-photo-qr-link-refused")
        app.terminate()

        app = openIntake("plain")
        XCTAssertTrue(app.otherElements["photoNothingRead"].waitForExistence(timeout: 20))
        XCTAssertFalse(app.staticTexts["photoRefusedLink"].exists)
        XCTAssertFalse(app.otherElements["decisionCard"].exists)
        attach(app, "SCAN-photo-nothing-read")
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
