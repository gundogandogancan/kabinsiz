import XCTest

/// §56 acceptance demo script, automated on the simulator (SIMULATOR_ONLY).
final class AcceptanceDemoUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    func testDemoTripFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest"]
        app.launch()

        app.buttons["demoTripButton"].tap()
        let tile = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'tripTile-'")).firstMatch
        XCTAssertTrue(tile.waitForExistence(timeout: 10))
        attach(app, "01-today-with-trip")
        tile.tap()

        XCTAssertTrue(app.staticTexts["capsuleSummary"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["syntheticBadge"].firstMatch.exists)
        attach(app, "02-trip-summary")

        // Lock the dinner look, then simulate a weather update and approve the diff.
        let lock = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'lock-' AND identifier ENDSWITH 'EVENING'")).firstMatch
        app.swipeUp()
        XCTAssertTrue(lock.waitForExistence(timeout: 5), "dinner slot must offer a lock")
        let lockID = lock.identifier
        lock.tap()
        XCTAssertEqual(app.buttons[lockID].label, "Kilitli")
        let simulate = app.buttons["simulateWeather"]
        for _ in 0..<6 where !simulate.isHittable { app.swipeUp() }
        simulate.tap()
        for _ in 0..<8 where !app.buttons["approveReplan"].isHittable { app.swipeDown() }
        XCTAssertTrue(app.otherElements["replanCard"].waitForExistence(timeout: 10))
        attach(app, "03-replan-diff")
        app.buttons["approveReplan"].tap()
        XCTAssertTrue(app.otherElements["replanCard"].waitForNonExistence(timeout: 5))
        for _ in 0..<6 where !app.buttons[lockID].exists { app.swipeUp() }
        XCTAssertEqual(app.buttons[lockID].label, "Kilitli", "lock must survive the approved replan")

        for _ in 0..<8 where !app.buttons["openSuitcase"].isHittable { app.swipeDown() }
        app.buttons["openSuitcase"].tap()
        let firstPack = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'pack-owned-'")).firstMatch
        XCTAssertTrue(firstPack.waitForExistence(timeout: 5))
        let packID = firstPack.identifier
        firstPack.tap()
        XCTAssertEqual(app.buttons[packID].label, "Valizde, işareti kaldır")
        attach(app, "04-suitcase")

        // Deleting the trip must leave the wardrobe untouched (T-TRV-013, app level).
        app.navigationBars.buttons.element(boundBy: 0).tap()
        let delete = app.buttons["deleteTrip"]
        for _ in 0..<10 where !delete.isHittable { app.swipeUp() }
        delete.tap()
        app.buttons["Seyahati ve valiz listesini sil"].firstMatch.tap()
        XCTAssertTrue(app.buttons["demoTripButton"].waitForExistence(timeout: 5))
        XCTAssertFalse(tile.exists)
        app.buttons["Dolabım"].tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'garment-'")).firstMatch.waitForExistence(timeout: 5))
    }

    func testScanDecisionCard() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest"]
        app.launch()
        app.buttons["Dolabım"].tap()
        app.buttons["loadSyntheticCloset"].tap()
        app.buttons["scanButton"].firstMatch.tap()

        let field = app.textFields["productCodeField"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("KB-TEE-01-WHT\n")
        XCTAssertTrue(app.otherElements["decisionCard"].waitForExistence(timeout: 5))
        attach(app, "05-decision-card")

        field.tap()
        field.clearAndType("KB-XXX-99\n")
        XCTAssertTrue(app.otherElements["notFoundCard"].waitForExistence(timeout: 5))
        attach(app, "06-not-found")

        field.tap()
        field.clearAndType("KB-JKT-01\n")
        XCTAssertTrue(app.otherElements["ambiguousCard"].waitForExistence(timeout: 5))
        attach(app, "07-ambiguous")
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}

private extension XCUIElement {
    func clearAndType(_ text: String) {
        if let value = value as? String, !value.isEmpty {
            typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count))
        }
        typeText(text)
    }
}
