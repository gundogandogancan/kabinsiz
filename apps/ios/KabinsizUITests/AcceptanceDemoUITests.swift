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

    /// WP15-04 on the simulator: the real Keychain KEK and the encrypted vault survive a relaunch, the
    /// consent switch persists, and "delete everything" leaves an empty vault plus a receipt.
    func testVaultSurvivesRelaunchAndDeletes() throws {
        let vaultName = "persist-\(UUID().uuidString)"
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestVault", vaultName]
        app.launch()
        app.buttons["Dolabım"].tap()
        app.buttons["loadSyntheticCloset"].tap()
        let garment = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'garment-'")).firstMatch
        XCTAssertTrue(garment.waitForExistence(timeout: 5))
        app.buttons["Benim Modelim"].tap()
        let toggle = app.switches["weatherConsentToggle"]
        for _ in 0..<6 where !toggle.isHittable { app.swipeUp() }
        XCTAssertEqual(toggle.value as? String, "1")
        toggle.switches.firstMatch.tap()
        XCTAssertEqual(toggle.value as? String, "0")
        sleep(1) // let the queued vault writes finish before the process is killed
        app.terminate()

        app.launch()
        app.buttons["Dolabım"].tap()
        XCTAssertTrue(garment.waitForExistence(timeout: 5), "wardrobe must be read back from the encrypted vault")
        app.buttons["Benim Modelim"].tap()
        for _ in 0..<6 where !toggle.isHittable { app.swipeUp() }
        XCTAssertEqual(toggle.value as? String, "0", "consent revocation must persist")
        let delete = app.buttons["deleteAllData"]
        for _ in 0..<6 where !delete.isHittable { app.swipeUp() }
        delete.tap()
        app.buttons["Dolap, vücut profili, seyahatler ve Fit Passport silinsin"].firstMatch.tap()
        let receipt = app.descendants(matching: .any)["deletionReceipt"].firstMatch
        for _ in 0..<6 where !receipt.exists { app.swipeUp() }
        XCTAssertTrue(receipt.waitForExistence(timeout: 5))
        attach(app, "08-deletion-receipt")
        sleep(1)
        app.terminate()

        app.launch()
        app.buttons["Dolabım"].tap()
        XCTAssertTrue(app.buttons["loadSyntheticCloset"].waitForExistence(timeout: 5), "wardrobe must be empty after delete-all")
        XCTAssertFalse(garment.exists)
    }

    /// §133.1 first proof (WP15-05, SIMULATOR_ONLY): neutral body → slider → typed measurement → undo →
    /// relaunch shows the same values → delete removes the body and its drawing.
    func testBodyStudioJourney() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestVault", "body-\(UUID().uuidString)"]
        app.launch()
        app.buttons["Benim Modelim"].tap()
        app.buttons["createNeutralBody"].tap()

        let waist = app.sliders["slider-WAIST"]
        XCTAssertTrue(waist.waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["value-WAIST"].label, "82 cm")
        XCTAssertEqual(waist.label, "Bel çevresi")
        XCTAssertTrue((waist.value as? String)?.hasSuffix("santimetre") == true, "spoken value must name the unit")
        XCTAssertTrue(app.descendants(matching: .any)["bodySilhouette"].exists)
        attach(app, "08b-body-neutral-start")

        bringIntoView(waist, in: app)
        waist.adjust(toNormalizedSliderPosition: 0.2)
        let shaped = app.staticTexts["value-WAIST"]
        XCTAssertTrue(wait(shaped, NSPredicate(format: "label != '82 cm'")))
        sleep(1) // commit debounce
        let draggedLabel = shaped.label
        attach(app, "09-body-studio-slider")

        let field = app.textFields["measurementValue"]
        for _ in 0..<6 where !field.isHittable { app.swipeUp() }
        field.tap()
        field.typeText("90")
        app.buttons["saveMeasurement"].tap()
        for _ in 0..<6 where !shaped.isHittable { app.swipeDown() }
        XCTAssertTrue(wait(shaped, NSPredicate(format: "label == '90 cm'")))
        XCTAssertFalse(waist.isEnabled, "a typed measurement is not moved by a stray touch")
        XCTAssertTrue(app.buttons["unlock-WAIST"].exists)
        attach(app, "10-body-studio-measured")

        let undo = app.buttons["bodyUndo"]
        for _ in 0..<8 where !undo.isHittable { app.swipeDown() }
        undo.tap()
        for _ in 0..<6 where !shaped.exists { app.swipeUp() }
        XCTAssertTrue(wait(shaped, NSPredicate(format: "label == %@", draggedLabel)))
        sleep(1)
        app.terminate()

        app.launch()
        app.buttons["Benim Modelim"].tap()
        XCTAssertTrue(shaped.waitForExistence(timeout: 5))
        XCTAssertEqual(shaped.label, draggedLabel, "the saved body must come back from the encrypted vault")
        let redo = app.buttons["bodyRedo"]
        for _ in 0..<8 where !redo.isHittable { app.swipeDown() }
        XCTAssertFalse(redo.isEnabled, "undo history is per session, never persisted")

        let delete = app.buttons["deleteBody"]
        for _ in 0..<10 where !delete.isHittable { app.swipeUp() }
        delete.tap()
        app.buttons["Vücut profilini ve çizimini sil"].firstMatch.tap()
        let create = app.buttons["createNeutralBody"]
        for _ in 0..<10 where !create.exists { app.swipeDown() }
        XCTAssertTrue(create.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["bodyDeletionReceipt"].exists)
        attach(app, "11-body-deleted")
        sleep(1)
        app.terminate()

        app.launch()
        app.buttons["Benim Modelim"].tap()
        XCTAssertTrue(app.buttons["createNeutralBody"].waitForExistence(timeout: 5), "deleted body must stay deleted")
        XCTAssertFalse(app.sliders["slider-WAIST"].exists)
    }

    /// Small drags in either direction until the element sits in the middle band of the screen. Big
    /// swipes overshoot in a List and lazily unload the row.
    private func bringIntoView(_ element: XCUIElement, in app: XCUIApplication) {
        let screen = app.frame
        for _ in 0..<15 {
            if element.exists, element.isHittable, element.frame.minY > screen.minY + 160, element.frame.maxY < screen.maxY - 160 { return }
            let below = !element.exists || element.frame.midY > screen.midY
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: below ? 0.65 : 0.35))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: below ? 0.45 : 0.55))
            start.press(forDuration: 0.05, thenDragTo: end)
        }
    }

    private func wait(_ element: XCUIElement, _ predicate: NSPredicate, timeout: TimeInterval = 5) -> Bool {
        XCTWaiter().wait(for: [XCTNSPredicateExpectation(predicate: predicate, object: element)], timeout: timeout) == .completed
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
