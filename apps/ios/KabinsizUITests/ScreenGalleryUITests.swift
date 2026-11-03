import XCTest

/// Screen gallery (SIMULATOR_ONLY): the screens no other UI test photographs, so that every screen of
/// the app has a current picture in docs/screenshots. Each step still checks that the screen opened.
final class ScreenGalleryUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    func testCaptureRemainingScreens() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest", "-mirrorFixture"]
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["worldAvatar"].waitForExistence(timeout: 10))
        sleep(2)
        attach(app, "G01-bugun-ana-sahne")

        // Empty wardrobe, then the example closet.
        app.tab("Dolabım")
        let load = app.buttons["loadSyntheticCloset"]
        XCTAssertTrue(load.waitForExistence(timeout: 5))
        attach(app, "G02-dolabim-bos")
        load.tap()

        // Scan screen, then a catalogue product with its size chart.
        app.tab("Dene")
        attach(app, "G03-dene-tara")
        app.buttons["mirrorScan"].tap()
        let field = app.textFields["productCodeField"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        attach(app, "G04-kod-ekrani")
        field.tap()
        field.typeText("KB-TEE-01-WHT\n")
        XCTAssertTrue(app.otherElements["decisionCard"].waitForExistence(timeout: 5))
        let use = app.buttons["scanUseInTryOn"]
        for _ in 0..<4 where !use.isHittable { app.swipeUp() }
        use.tap()
        XCTAssertTrue(app.staticTexts["tryOnSource"].waitForExistence(timeout: 5))
        attach(app, "G05-dene-katalog-urunu")
        let detail = app.buttons["tryOnDetail"]
        for _ in 0..<4 where !detail.isHittable { app.swipeUp() }
        detail.tap()
        XCTAssertTrue(app.descendants(matching: .any)["productDetail"].waitForExistence(timeout: 5))
        attach(app, "G06-urun-detayi-katalog")
        let chart = app.descendants(matching: .any)["productSizeChart"]
        for _ in 0..<6 where !(chart.exists && chart.isHittable) { app.swipeUp() }
        attach(app, "G07-urun-kumas-kimlik")
        for _ in 0..<4 { app.swipeUp() }
        attach(app, "G08-urun-kimligi-magaza")
        app.buttons["Kapat"].firstMatch.tap()

        // Mirror: product picker sheet.
        let open = app.buttons["openMirror"]
        XCTAssertTrue(open.waitForExistence(timeout: 5))
        for _ in 0..<4 where !open.isHittable { app.swipeUp() }
        open.tap()
        let change = app.buttons["mirrorChange"]
        XCTAssertTrue(change.waitForExistence(timeout: 10))
        sleep(2)
        attach(app, "G09-canli-ayna-katalog-urunu")
        change.tap()
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'mirrorChoice-'")).firstMatch.waitForExistence(timeout: 5))
        attach(app, "G10-canli-ayna-urun-sec")
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'mirrorChoice-'")).element(boundBy: 2).tap()
        sleep(2)
        attach(app, "G11-canli-ayna-baska-urun")
        app.buttons["mirrorClose"].tap()

        // Profile: top and the privacy section.
        app.openProfile()
        XCTAssertTrue(app.navigationBars["Benim Modelim"].waitForExistence(timeout: 5))
        attach(app, "G12-benim-modelim")
        let create = app.buttons["createNeutralBody"]
        if create.exists { create.tap(); sleep(2); attach(app, "G13-benim-modelim-3b-govde") }
        let delete = app.buttons["deleteAllData"]
        for _ in 0..<10 where !delete.isHittable { app.swipeUp() }
        attach(app, "G14-gizlilik")
        app.tab("Bugün")

        // Why this look, lower part (reasons and scene).
        app.buttons["worldReasonChip"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["lookSuggestions"].waitForExistence(timeout: 5))
        app.swipeUp()
        attach(app, "G15-neden-bu-kombin")
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
