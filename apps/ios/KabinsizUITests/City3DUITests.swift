import XCTest

/// v2.8 UI28-05 on the simulator (SIMULATOR_ONLY): the street behind the figure is real geometry drawn by
/// RealityKit, the truth line says what is on screen, rain swaps the baked surface without reloading the
/// city, and the governor's 2D fallback is labelled as a frame, never as 3D. Frame rates read here are
/// simulator numbers on a Mac GPU, not device numbers.
final class City3DUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    func testCity3DStreetWeatherAndCities() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest"]
        app.launch()
        let truth = app.staticTexts["worldTruthLabel"]
        XCTAssertTrue(truth.waitForExistence(timeout: 10))
        waitForTier(truth, "CITY_3D")
        XCTAssertTrue(truth.label.contains("3B şehir, hazır ışık"), truth.label)
        XCTAssertTrue(truth.label.hasSuffix("beden uyumunu göstermez"))
        sleep(2)
        attach(app, "UI28-05-istanbul-dry")

        // The garment is still what a tap hits: the street has no collision shapes.
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.4)).tap()
        XCTAssertTrue(app.buttons["trayDone"].waitForExistence(timeout: 5), "a tap on the garment opens its sheet over the 3D street")
        attach(app, "UI28-05-istanbul-sheet")
        app.buttons["trayDone"].tap()

        // Rain preview: the baked wet surface replaces the dry one; the city is not reloaded into 2D.
        let chip = app.buttons["weatherChip"]
        chip.tap()
        let rain = app.switches["cityRainToggle"]
        XCTAssertTrue(app.reveal(rain), "the rain preview is in the city sheet, below the world streets")
        rain.coordinate(withNormalizedOffset: CGVector(dx: 0.93, dy: 0.5)).tap()
        app.buttons["Bitti"].tap()
        // Still the 3D street (full or, when the simulator's rate drops under rain, reduced), never the 2D frame.
        XCTAssertTrue((truth.value as? String)?.hasPrefix("CITY_3D") == true, "\(String(describing: truth.value))")
        sleep(3)
        attach(app, "UI28-05-istanbul-rain-preview")
        chip.tap()
        XCTAssertTrue(app.reveal(app.switches["cityRainToggle"]))
        app.switches["cityRainToggle"].coordinate(withNormalizedOffset: CGVector(dx: 0.93, dy: 0.5)).tap()

        // Barcelona: another street, loaded on demand.
        let bcn = app.buttons["city-ES-BCN"]
        for _ in 0..<4 where !(bcn.exists && bcn.isHittable) { app.collectionViews.firstMatch.swipeDown() }
        XCTAssertTrue(bcn.waitForExistence(timeout: 5))
        bcn.tap()
        app.buttons["Bitti"].tap()
        waitForTier(truth, "CITY_3D")
        sleep(2)
        attach(app, "UI28-05-barcelona-dry")

        // The scene section says what the street is and how fast it updates on this machine.
        app.buttons["worldReasonChip"].tap()
        let rate = app.staticTexts["sceneRate"]
        let tier = app.staticTexts["sceneTier"]
        XCTAssertTrue(app.reveal(tier), "the scene section of the why sheet")
        XCTAssertTrue(tier.label.contains("3B şehir"), tier.label)
        XCTAssertTrue(tier.label.contains("önceden hesaplandı") || tier.label.contains("azaltılmış"), tier.label)
        let tierNote = XCTAttachment(string: "scene tier on the simulator: \(tier.label)")
        tierNote.name = "UI28-05-scene-tier-simulator"
        tierNote.lifetime = .keepAlways
        add(tierNote)
        if !app.reveal(rate) { app.buttons["Kapat"].tap(); sleep(7); app.buttons["worldReasonChip"].tap() }
        XCTAssertTrue(app.reveal(rate) || rate.waitForExistence(timeout: 10), "the update rate is measured")
        let shot = XCTAttachment(string: "scene rate on the simulator: \(rate.label)")
        shot.name = "UI28-05-scene-rate-simulator"
        shot.lifetime = .keepAlways
        add(shot)
        attach(app, "UI28-05-why-scene")
        app.buttons["Kapat"].tap()
        chip.tap()
        app.buttons["city-TR-IST"].tap()
        app.buttons["Bitti"].tap()
    }

    /// UI28-T024: when the governor steps down to the frame, the line says "Blender kadrajı" and never "3B şehir".
    func testFrameFallbackIsLabelled() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest", "-sceneTier", "FRAME_2D"]
        app.launch()
        let truth = app.staticTexts["worldTruthLabel"]
        XCTAssertTrue(truth.waitForExistence(timeout: 10))
        sleep(2)
        XCTAssertEqual(truth.value as? String, "FRAME_2D")
        XCTAssertTrue(truth.label.contains("şehir Blender kadrajı"), truth.label)
        XCTAssertFalse(truth.label.contains("3B şehir"), truth.label)
        app.buttons["worldReasonChip"].tap()
        let tier = app.staticTexts["sceneTier"]
        XCTAssertTrue(app.reveal(tier), "the scene section of the why sheet")
        XCTAssertTrue(tier.label.contains("3B değil"), tier.label)
        attach(app, "UI28-05-frame-fallback")
    }

    /// UI28-T065: a world city with no owned street. Either Apple's Look Around photo shows (credited to
    /// Apple, never called our 3D city), or the screen says why not and shows the neutral studio. Which one
    /// depends on the network and Apple's coverage; both are honest outcomes and both are recorded.
    func testWorldStreetPhotoOrHonestFallback() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest", "-worldStreet", "FR-PAR"]
        app.launch()
        let truth = app.staticTexts["worldTruthLabel"]
        XCTAssertTrue(truth.waitForExistence(timeout: 10))
        let chip = app.buttons["weatherChip"]
        XCTAssertTrue(chip.label.contains("Paris"), chip.label)
        let shown = expectation(for: NSPredicate(format: "value == %@", "STREET_PHOTO"), evaluatedWith: truth)
        let outcome = XCTWaiter().wait(for: [shown], timeout: 30)
        XCTAssertFalse(truth.label.contains("3B şehir"), truth.label)
        XCTAssertTrue(truth.label.hasSuffix("beden uyumunu göstermez"), truth.label)
        if outcome == .completed {
            XCTAssertTrue(truth.label.contains("cadde fotoğrafı: Apple"), truth.label)
        } else {
            XCTAssertTrue(truth.label.contains("nötr stüdyo"), truth.label)
        }
        sleep(2)
        attach(app, outcome == .completed ? "UI28-world-paris-lookaround" : "UI28-world-paris-fallback")
        chip.tap()
        let status = app.staticTexts["streetStatus"]
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        // Consent was not turned off, so "kapalı" would mean the launch race (closed start ledger) is back.
        XCTAssertFalse(status.label.contains("kapalı"), status.label)
        let note = XCTAttachment(string: "Look Around on the simulator: \(status.label)")
        note.name = "UI28-world-paris-status"
        note.lifetime = .keepAlways
        add(note)
        attach(app, "UI28-world-city-sheet")
        // Back to an owned street: the photo goes, the 3D street returns.
        app.buttons["city-TR-IST"].tap()
        app.buttons["Bitti"].tap()
        waitForTier(truth, "CITY_3D")
    }

    private func waitForTier(_ truth: XCUIElement, _ tier: String, timeout: TimeInterval = 25) {
        // "CITY_3D" also accepts the governor's reduced 3D tier (CITY_3D_REDUCED); FRAME_2D is exact.
        let done = expectation(for: NSPredicate(format: "value BEGINSWITH %@", tier), evaluatedWith: truth)
        wait(for: [done], timeout: timeout)
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
