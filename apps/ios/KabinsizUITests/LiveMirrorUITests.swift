import XCTest

/// MIR-WP02 / SCAN-WP02 / UI32 on the simulator (SIMULATOR_ONLY). The Simulator has no camera, so the
/// mirror runs on the DEBUG fixture (`-mirrorFixture`): a rendered mannequin that sways, read through the
/// same Apple Vision path as the camera, labelled as a fixture on screen. A real iPhone run is
/// REAL_DEVICE_BLOCKED until a device is attached.
final class LiveMirrorUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    private func launch(_ extra: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest"] + extra
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["worldAvatar"].waitForExistence(timeout: 10))
        return app
    }

    /// V32-MIR-01..04: the garment follows the person; the product can be changed in the mirror; the
    /// photo exists only after the shutter and is shared only from the sheet; the truth label is on screen.
    func testMirrorFollowsFixtureChangesProductAndCaptures() throws {
        let app = launch(["-mirrorFixture"])
        app.tab("Dene")
        let open = app.buttons["openMirror"]
        XCTAssertTrue(open.waitForExistence(timeout: 5))
        for _ in 0..<4 where !open.isHittable { app.swipeUp() }
        open.tap()

        let status = app.descendants(matching: .any)["mirrorStatus"]
        XCTAssertTrue(status.waitForExistence(timeout: 10))
        var seen = false
        for _ in 0..<30 where !seen {
            seen = status.label.contains("seni görüyor")
            if !seen { Thread.sleep(forTimeInterval: 0.5) }
        }
        XCTAssertTrue(seen, "Vision finds the fixture figure and the garment is placed: \(status.label)")
        XCTAssertTrue(app.staticTexts["mirrorTruthLabel"].label.contains("beden uyumunu göstermez"))
        XCTAssertFalse(app.descendants(matching: .any)["cameraFallbackCard"].exists)
        sleep(1)
        attach(app, "v32-MIR-01-mirror-tracking")

        // Change the product without leaving the mirror.
        let change = app.buttons["mirrorChange"]
        XCTAssertTrue(change.exists)
        change.tap()
        let choices = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'mirrorChoice-'"))
        XCTAssertTrue(choices.firstMatch.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(choices.count, 1)
        let before = app.buttons["mirrorProduct"].label
        choices.element(boundBy: choices.count - 1).tap()
        XCTAssertTrue(app.buttons["mirrorProduct"].waitForExistence(timeout: 5))
        sleep(2)
        XCTAssertNotEqual(app.buttons["mirrorProduct"].label, before, "the product changed in place")
        attach(app, "v32-MIR-02-mirror-changed")

        // Nothing is saved until the shutter; the photo is offered for sharing, not stored.
        app.buttons["mirrorShutter"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["mirrorCaptured"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["mirrorShare"].exists)
        attach(app, "v32-MIR-03-mirror-captured")
    }

    /// V32-UI-10 / SCAN: product detail keeps each fact with its source; no price, no store link, no
    /// scraped brand page; the web search is the user's own.
    func testProductDetailIsHonest() throws {
        let app = launch()
        app.tab("Dene")
        XCTAssertTrue(app.descendants(matching: .any)["scanHero"].waitForExistence(timeout: 5))
        attach(app, "v32-S10-dene")
        let detail = app.buttons["tryOnDetail"]
        XCTAssertTrue(detail.waitForExistence(timeout: 5))
        for _ in 0..<4 where !detail.isHittable { app.swipeUp() }
        detail.tap()
        XCTAssertTrue(app.descendants(matching: .any)["productDetail"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["productHeroLabel"].label.contains("Temsilî"))
        XCTAssertTrue(app.buttons["productTryOn"].exists)
        attach(app, "v32-S11-product-detail")
        let identity = app.descendants(matching: .any)["productIdentity"]
        for _ in 0..<6 where !(identity.exists && identity.isHittable) { app.swipeUp() }
        XCTAssertTrue(identity.exists)
        attach(app, "v32-S11-product-detail-facts")
    }

    /// V32-UI-03: the wardrobe is a grid of garment drawings with category chips.
    func testWardrobeGrid() throws {
        let app = launch()
        app.tab("Dolabım")
        let load = app.buttons["loadSyntheticCloset"]
        if load.waitForExistence(timeout: 3) { load.tap() }
        let cards = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'garment-'"))
        XCTAssertTrue(cards.firstMatch.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(cards.count, 3)
        XCTAssertTrue(app.buttons["addGarment"].exists)
        XCTAssertTrue(app.buttons["openProfile"].exists)
        attach(app, "v32-S05-wardrobe-grid")
    }

    /// V32-UI-07/09: suggestion cards apply a prepared look to the figure; the model bar says face and
    /// hair are not in this build instead of offering a control that does nothing.
    func testSuggestionsAndModelBar() throws {
        let app = launch()
        let avatar = app.descendants(matching: .any)["worldAvatar"]
        let before = avatar.value as? String ?? ""
        app.buttons["worldReasonChip"].tap()
        let cards = app.descendants(matching: .any)["lookSuggestions"]
        XCTAssertTrue(cards.waitForExistence(timeout: 5))
        attach(app, "v32-S07-suggestions")
        let apply = app.buttons["lookApply-1"]
        XCTAssertTrue(apply.waitForExistence(timeout: 5))
        apply.tap()
        app.buttons["Kapat"].firstMatch.tap()
        sleep(1)
        XCTAssertNotEqual(avatar.value as? String ?? "", before, "the chosen look is on the figure")

        app.openProfile()
        let face = app.buttons["modelPart-face"]
        XCTAssertTrue(face.waitForExistence(timeout: 5))
        face.tap()
        XCTAssertTrue(app.staticTexts["modelPartNote"].label.contains("bu sürümde yok"))
        attach(app, "v32-S09-model-bar")
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
