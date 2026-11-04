import XCTest

/// §56 acceptance demo script, automated on the simulator (SIMULATOR_ONLY).
final class AcceptanceDemoUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    func testDemoTripFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest"]
        app.launch()

        // v2.8: travel opens from the city menu (ADR-011).
        XCTAssertTrue(app.buttons["weatherChip"].waitForExistence(timeout: 10))
        app.buttons["weatherChip"].tap()
        XCTAssertTrue(app.buttons["worldPlan"].waitForExistence(timeout: 5))
        app.buttons["worldPlan"].tap()
        XCTAssertTrue(app.buttons["demoTripButton"].waitForExistence(timeout: 10))
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
        app.tab("Dolabım")
        XCTAssertTrue(app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'garment-'")).firstMatch.waitForExistence(timeout: 5))
    }

    func testScanDecisionCard() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest"]
        app.launch()
        app.tab("Dolabım")
        app.buttons["loadSyntheticCloset"].tap()
        // v2.8: scanning lives in Dene (ADR-011); without a camera scanner the code entry is the way in.
        app.tab("Dene")
        XCTAssertTrue(app.buttons["mirrorScan"].waitForExistence(timeout: 5))
        app.buttons["mirrorScan"].tap()

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

        // D01: the found product goes into the same try-on session, labelled with its source.
        field.tap()
        field.clearAndType("KB-TEE-01-WHT\n")
        let use = app.buttons["scanUseInTryOn"]
        for _ in 0..<4 where !use.isHittable { app.swipeUp() }
        use.tap()
        let source = app.staticTexts["tryOnSource"]
        XCTAssertTrue(source.waitForExistence(timeout: 5))
        XCTAssertTrue(source.label.contains("KB-TEE-01-WHT"), source.label)
        attach(app, "07b-dene-product-from-code")
        let onModel = app.buttons["tryOnModel"]
        for _ in 0..<4 where !onModel.isHittable { app.swipeUp() }
        onModel.tap()
        XCTAssertTrue(app.tabBars.buttons["Bugün"].isSelected)
        let avatar = app.descendants(matching: .any)["worldAvatar"]
        XCTAssertTrue(avatar.waitForExistence(timeout: 5))
        XCTAssertTrue((avatar.value as? String)?.contains("Üst:") == true)
        attach(app, "07c-dene-on-model")
    }

    /// WP15-04 on the simulator: the real Keychain KEK and the encrypted vault survive a relaunch, the
    /// consent switch persists, and "delete everything" leaves an empty vault plus a receipt.
    func testVaultSurvivesRelaunchAndDeletes() throws {
        let vaultName = "persist-\(UUID().uuidString)"
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestVault", vaultName]
        app.launch()
        app.tab("Dolabım")
        app.buttons["loadSyntheticCloset"].tap()
        let garment = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'garment-'")).firstMatch
        XCTAssertTrue(garment.waitForExistence(timeout: 5))
        app.openProfile()
        let toggle = app.switches["weatherConsentToggle"]
        for _ in 0..<6 where !toggle.isHittable { app.scrollProfile(up: true) }
        XCTAssertEqual(toggle.value as? String, "1")
        flip(toggle, to: "0")
        XCTAssertEqual(toggle.value as? String, "0")
        sleep(1) // let the queued vault writes finish before the process is killed
        app.terminate()

        app.launch()
        app.tab("Dolabım")
        XCTAssertTrue(garment.waitForExistence(timeout: 5), "wardrobe must be read back from the encrypted vault")
        app.openProfile()
        for _ in 0..<6 where !toggle.isHittable { app.scrollProfile(up: true) }
        XCTAssertEqual(toggle.value as? String, "0", "consent revocation must persist")
        let delete = app.buttons["deleteAllData"]
        for _ in 0..<6 where !delete.isHittable { app.scrollProfile(up: true) }
        delete.tap()
        app.buttons["Dolap, vücut profili, seyahatler ve Fit Passport silinsin"].firstMatch.tap()
        let receipt = app.descendants(matching: .any)["deletionReceipt"].firstMatch
        for _ in 0..<6 where !receipt.exists { app.scrollProfile(up: true) }
        XCTAssertTrue(receipt.waitForExistence(timeout: 5))
        attach(app, "08-deletion-receipt")
        sleep(1)
        app.terminate()

        app.launch()
        app.tab("Dolabım")
        XCTAssertTrue(app.buttons["loadSyntheticCloset"].waitForExistence(timeout: 5), "wardrobe must be empty after delete-all")
        XCTAssertFalse(garment.exists)
    }

    /// §133.1 first proof (WP15-05, SIMULATOR_ONLY): neutral body → slider → typed measurement → undo →
    /// relaunch shows the same values → delete removes the body and its drawing.
    func testBodyStudioJourney() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestVault", "body-\(UUID().uuidString)"]
        app.launch()
        app.openProfile()
        app.buttons["createNeutralBody"].tap()

        XCTAssertTrue(app.descendants(matching: .any)["body3D"].waitForExistence(timeout: 5), "a 3D-capable budget shows the neutral 3D body")
        attach(app, "08b-body-neutral-start")
        // The 3D view is tall, so the sliders start below the fold (List rows load lazily).
        let waist = app.sliders["slider-WAIST"]
        bringIntoView(waist, in: app)
        XCTAssertTrue(waist.waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["value-WAIST"].label, "82 cm")
        XCTAssertEqual(waist.label, "Bel çevresi")
        XCTAssertTrue((waist.value as? String)?.hasSuffix("santimetre") == true, "spoken value must name the unit")

        bringIntoView(waist, in: app)
        waist.dragThumb(to: 0.2)
        let shaped = app.staticTexts["value-WAIST"]
        XCTAssertTrue(wait(shaped, NSPredicate(format: "label != '82 cm'")), "one drag moves the slider")
        sleep(1) // commit debounce
        let draggedLabel = shaped.label
        attach(app, "09-body-studio-slider")

        let field = app.textFields["measurementValue"]
        for _ in 0..<6 where !field.isHittable { app.scrollProfile(up: true) }
        // Under load the simulator keyboard can swallow keys typed before it is ready: wait for it,
        // type, and check the field really holds the value before saving.
        for _ in 0..<3 where (field.value as? String) != "90" {
            field.tap()
            XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
            field.clearAndType("90")
        }
        XCTAssertEqual(field.value as? String, "90")
        app.buttons["saveMeasurement"].tap()
        bringIntoView(shaped, in: app)
        XCTAssertTrue(wait(shaped, NSPredicate(format: "label == '90 cm'")))
        XCTAssertFalse(waist.isEnabled, "a typed measurement is not moved by a stray touch")
        XCTAssertTrue(app.buttons["unlock-WAIST"].exists)
        attach(app, "10-body-studio-measured")

        let undo = app.buttons["bodyUndo"]
        bringIntoView(undo, in: app, above: true)
        undo.tap()
        bringIntoView(shaped, in: app)
        XCTAssertTrue(wait(shaped, NSPredicate(format: "label == %@", draggedLabel)))
        sleep(1)
        app.terminate()

        app.launch()
        app.openProfile()
        bringIntoView(shaped, in: app)
        XCTAssertTrue(shaped.waitForExistence(timeout: 5))
        XCTAssertEqual(shaped.label, draggedLabel, "the saved body must come back from the encrypted vault")
        let redo = app.buttons["bodyRedo"]
        for _ in 0..<8 where !redo.isHittable { app.scrollProfile(up: false) }
        XCTAssertFalse(redo.isEnabled, "undo history is per session, never persisted")

        let delete = app.buttons["deleteBody"]
        for _ in 0..<10 where !delete.isHittable { app.scrollProfile(up: true) }
        delete.tap()
        let confirm = app.buttons["Vücut profilini ve çizimini sil"].firstMatch
        XCTAssertTrue(confirm.waitForExistence(timeout: 5), "the delete confirmation is up")
        confirm.tap()
        let create = app.buttons["createNeutralBody"]
        for _ in 0..<10 where !create.exists { app.scrollProfile(up: false) }
        XCTAssertTrue(create.waitForExistence(timeout: 5))
        // The receipt is the row under the create button; a List loads rows lazily, so bring it in.
        let receipt = app.staticTexts["bodyDeletionReceipt"]
        bringIntoView(receipt, in: app)
        XCTAssertTrue(receipt.waitForExistence(timeout: 5), "deletion leaves a receipt")
        attach(app, "11-body-deleted")
        sleep(1)
        app.terminate()

        app.launch()
        app.openProfile()
        XCTAssertTrue(app.buttons["createNeutralBody"].waitForExistence(timeout: 5), "deleted body must stay deleted")
        XCTAssertFalse(app.sliders["slider-WAIST"].exists)
    }

    /// Small drags in either direction until the element sits in the middle band of the screen. Big
    /// swipes overshoot in a List and lazily unload the row.
    /// V15-T-DEV-02 on the simulator: with an injected thermal-critical signal the body studio says so
    /// calmly, without numbers, and the user can still shape and save (SIMULATOR_ONLY fault injection).
    func testThermalCriticalKeepsBodyStudioUsable() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestVault", "hot-\(UUID().uuidString)", "-deviceFault", "thermalCritical"]
        app.launch()
        app.openProfile()
        app.buttons["createNeutralBody"].tap()

        let note = app.staticTexts["deviceNote"]
        XCTAssertTrue(note.waitForExistence(timeout: 5))
        // SURVIVAL budget is 2D_CARD: the outline replaces the 3D body, and says so.
        XCTAssertTrue(app.descendants(matching: .any)["bodySilhouette"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["body3D"].exists)
        XCTAssertEqual(app.staticTexts["bodyFidelityLabel"].label, "Basit siluet. Görünüm, beden uyumunun kanıtı değildir.")
        XCTAssertTrue(note.label.contains("ısındı"))
        XCTAssertNil(note.label.rangeOfCharacter(from: CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "%°"))), "no temperature or percentage")

        // The note adds a row, so the waist slider may start below the fold (List rows load lazily).
        let waist = app.sliders["slider-WAIST"]
        bringIntoView(waist, in: app)
        XCTAssertTrue(waist.waitForExistence(timeout: 5))
        waist.dragThumb(to: 0.8)
        let shaped = app.staticTexts["value-WAIST"]
        XCTAssertTrue(wait(shaped, NSPredicate(format: "label != '82 cm'")))
        sleep(1) // commit debounce
        let saved = shaped.label
        XCTAssertFalse(app.staticTexts["bodyMessage"].exists, "the save must not be refused while hot")
        attach(app, "12-body-studio-thermal-critical")

        app.terminate()
        app.launch()
        app.openProfile()
        let relaunched = app.staticTexts["value-WAIST"]
        bringIntoView(relaunched, in: app)
        XCTAssertTrue(wait(relaunched, NSPredicate(format: "label == %@", saved)), "saved while hot survives relaunch")
    }

    /// ADR-007: the user turns their neutral body by hand (drag, preset angles); it never turns by itself.
    func testBody3DRotatesByHand() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestVault", "turn-\(UUID().uuidString)"]
        app.launch()
        app.openProfile()
        app.buttons["createNeutralBody"].tap()

        let model = app.descendants(matching: .any)["body3D"]
        XCTAssertTrue(model.waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["bodyFidelityLabel"].label, "Nötr 3B model. Görünüm, beden uyumunun kanıtı değildir.")
        XCTAssertTrue((model.value as? String)?.hasPrefix("Önden") == true)
        sleep(2)
        XCTAssertTrue((model.value as? String)?.hasPrefix("Önden") == true, "the idle sway never turns it away from the front")
        attach(app, "13-body-3d-front")

        app.buttons["bodyAngle-side"].tap()
        XCTAssertTrue(wait(model, NSPredicate(format: "value BEGINSWITH 'Yandan'")))
        sleep(1)
        attach(app, "14-body-3d-side")
        app.buttons["bodyAngle-back"].tap()
        XCTAssertTrue(wait(model, NSPredicate(format: "value BEGINSWITH 'Arkadan'")))
        sleep(1)
        attach(app, "15-body-3d-back")

        // A horizontal drag turns it; the angle follows the finger.
        app.buttons["bodyAngle-front"].tap()
        XCTAssertTrue(wait(model, NSPredicate(format: "value BEGINSWITH 'Önden'")))
        let start = model.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.5))
        start.press(forDuration: 0.05, thenDragTo: model.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.5)))
        XCTAssertTrue(wait(model, NSPredicate(format: "NOT (value BEGINSWITH 'Önden')")), "drag must turn the body")
        sleep(1)
        attach(app, "16-body-3d-dragged")
    }

    /// Small drags until `element` sits comfortably on screen. A row that is not loaded yet has no frame,
    /// so the caller says which way to look (`above` for rows higher up the list).
    /// Tap a Toggle's switch the way a person does. On iOS 26 the Toggle element spans the whole row
    /// (title and footnote), so a tap at its centre lands on the text and does nothing; tap the
    /// switch's own frame when it is smaller than the row, else the trailing edge on the first line.
    private func flip(_ toggle: XCUIElement, to value: String) {
        let changed = NSPredicate(format: "value == %@", value)
        let inner = toggle.switches.firstMatch
        for attempt in 0..<3 where !changed.evaluate(with: toggle) {
            if attempt == 0, inner.exists, inner.frame.width < toggle.frame.width * 0.5 {
                inner.tap()
            } else {
                let knob = CGPoint(x: toggle.frame.maxX - 36, y: toggle.frame.minY + 22)
                toggle.coordinate(withNormalizedOffset: .zero)
                    .withOffset(CGVector(dx: knob.x - toggle.frame.minX, dy: knob.y - toggle.frame.minY)).tap()
            }
            let deadline = Date().addingTimeInterval(2)
            while Date() < deadline, !changed.evaluate(with: toggle) { Thread.sleep(forTimeInterval: 0.2) }
        }
    }

    private func bringIntoView(_ element: XCUIElement, in app: XCUIApplication, above: Bool = false) {
        let screen = app.frame
        for _ in 0..<15 {
            // Below the profile's fixed 3D figure (where there is one) and clear of the bottom edge.
            if element.exists, element.isHittable, element.frame.minY > app.profileFigureBottom + 8,
               element.frame.maxY < screen.maxY - 40 { return }
            let below = element.exists ? element.frame.midY > screen.midY : !above
            // Both ends inside the list: the profile's 3D figure sits fixed above it and a drag there
            // turns the figure instead of scrolling.
            // A short step (about a row), so a row cannot jump over the band below the figure.
            // On the list's right margin, outside the row cards: in the middle a drag can land on a
            // slider's thumb and grab it instead of scrolling (seen 2026-11-04 after undo jumped to the top).
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.97, dy: below ? 0.78 : 0.64))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.97, dy: below ? 0.64 : 0.78))
            // Hold before letting go: no fling, so the list is still when the next tap or drag lands
            // (a tap on a moving list only stops it).
            start.press(forDuration: 0.05, thenDragTo: end, withVelocity: .default, thenHoldForDuration: 0.3)
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

extension XCUIApplication {
    /// Bottom edge of the profile's fixed 3D figure strip (angle buttons included), or the top of the
    /// screen plus a margin when the profile shows no 3D figure.
    var profileFigureBottom: CGFloat {
        let figure = descendants(matching: .any).matching(NSPredicate(format: "identifier IN {'body3D', 'standIn3D'}")).firstMatch
        guard figure.exists else { return frame.minY + 160 }
        let angle = buttons["bodyAngle-front"]
        return max(figure.frame.maxY, angle.exists ? angle.frame.maxY : 0)
    }

    /// Scrolls the profile's list by a drag in the lower part of the screen. Not `swipeUp()`: the
    /// middle of the screen (and of the list, which runs under it) is the profile's fixed 3D figure,
    /// where a vertical swipe does not scroll.
    func scrollProfile(up: Bool) {
        // Right margin, outside the row cards, so the drag never grabs a slider thumb.
        let low = coordinate(withNormalizedOffset: CGVector(dx: 0.97, dy: 0.88))
        let high = coordinate(withNormalizedOffset: CGVector(dx: 0.97, dy: 0.62))
        if up {
            low.press(forDuration: 0.05, thenDragTo: high, withVelocity: .default, thenHoldForDuration: 0.3)
        } else {
            high.press(forDuration: 0.05, thenDragTo: low, withVelocity: .default, thenHoldForDuration: 0.3)
        }
    }
}

extension XCUIElement {
    /// Drags a slider the way a person does: finger down on the thumb, a short hold, then a slow drag.
    /// `adjust(toNormalizedSliderPosition:)` starts moving at once; on a loaded simulator the List's
    /// scroll gesture then takes the touch and the slider never starts tracking (measured 2026-11-04:
    /// no editing-began, only a release at the old value). That is a test-input artefact, not a frozen
    /// app (no frame gap over 330 ms in those runs). A UIKit `UISlider` in its place failed just as often
    /// (3 of 4 runs, measured on v25/living-world), so this is the test's input, not the slider control.
    func dragThumb(to position: CGFloat) {
        let inset: CGFloat = 14 // about half the thumb: the thumb's centre never reaches the track ends
        let width = frame.width, midY = frame.height / 2
        func point(_ p: CGFloat) -> XCUICoordinate {
            coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: inset + p * (width - 2 * inset), dy: midY))
        }
        point(normalizedSliderPosition).press(forDuration: 0.4, thenDragTo: point(position),
                                              withVelocity: .slow, thenHoldForDuration: 0.2)
    }
}
