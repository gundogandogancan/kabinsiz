import XCTest

/// UI20-WP03/WP04 acceptance on the simulator (SIMULATOR_ONLY): navigation contract, the single
/// primary action, no first-launch permission prompts, the honest empty home, and the component catalogue.
final class AtelierNavigationUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    /// v2.8 H01 + UI20-T-006/T-008 (ADR-011): the first screen is the dressed figure in the city. Four
    /// tabs `Bugün | Dolabım | Dene | Ben`, no scan tab or toolbar button, no slot rails or side
    /// columns, at most two strong actions, no permission prompt, no invented weather.
    func testFirstLaunchWorldAndTabs() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest"]
        app.launch()

        let avatar = app.descendants(matching: .any)["worldAvatar"]
        XCTAssertTrue(avatar.waitForExistence(timeout: 10), "the figure is the first thing on screen")
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        XCTAssertEqual(springboard.alerts.count, 0, "UI20-T-008: no permission prompt on first launch")

        let tabs = app.tabBars.buttons
        XCTAssertEqual((0..<tabs.count).map { tabs.element(boundBy: $0).label }, ["Bugün", "Dolabım", "Dene", "Ben"])
        XCTAssertFalse(app.buttons["scanButton"].exists, "no separate Tara button (v2.6/v2.8)")

        // UI28-T015: no persistent slot rail or side column on the scene.
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'slot-'")).count, 0)
        for gone in ["worldTurn", "worldRainPreview", "worldWhy", "worldPlan", "worldMirror", "worldScan"] {
            XCTAssertFalse(app.buttons[gone].exists, gone)
        }
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'primary.'")).count, 1, "one dominant action")
        for id in ["primary.newLook", "homeTryOn", "weatherChip"] {
            XCTAssertTrue(app.buttons[id].isHittable, id)
            XCTAssertGreaterThanOrEqual(app.buttons[id].frame.height, 44, id)
        }
        XCTAssertGreaterThan(app.buttons["primary.newLook"].frame.width, app.buttons["homeTryOn"].frame.width, "Yeni kombin leads")
        XCTAssertTrue(app.buttons["weatherChip"].label.contains("İstanbul · Hava verisi yok"), "UI28-T008: no weather is invented")
        XCTAssertTrue(app.staticTexts["worldLookKind"].label.contains("sentetik"), "an example look says so")
        XCTAssertTrue(app.staticTexts["worldTruthLabel"].label.contains("beden uyumunu göstermez"))
        XCTAssertTrue(app.buttons["worldCreateModel"].isHittable, "UI28-T012: the stand-in body says it is one")
        attach(app, "v28-H01-world-first-launch")

        // The stand-in saved nothing.
        app.buttons["worldCreateModel"].tap()
        XCTAssertTrue(app.tabBars.buttons["Ben"].isSelected)
        XCTAssertTrue(app.buttons["createNeutralBody"].waitForExistence(timeout: 5))
    }

    /// v2.8 H02/H03 (UI28-T013/T014/T016): touching the garment on the figure opens one short sheet
    /// with the piece on and alternatives; a piece goes on at once; undo restores; the scene lifts so
    /// the sheet does not cover the figure. "Yeni kombin" dresses the same figure in the next look,
    /// and its note offers undo.
    func testWorldDressingSwapUndoAndNewLook() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest"]
        app.launch()
        let avatar = app.descendants(matching: .any)["worldAvatar"]
        XCTAssertTrue(avatar.waitForExistence(timeout: 10))
        let before = avatar.value as? String ?? ""
        XCTAssertFalse(before.isEmpty)
        sleep(1)

        // The torso of the figure sits a little above the middle of the screen.
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.4)).tap()
        XCTAssertTrue(app.buttons["trayDone"].waitForExistence(timeout: 5), "a tap on the garment opens its sheet")
        let items = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'trayItem-'"))
        XCTAssertGreaterThan(items.count, 1)
        XCTAssertLessThanOrEqual(items.count, 4, "the piece on and at most three alternatives")
        attach(app, "v28-H02-garment-sheet")
        let pickID = try XCTUnwrap((0..<items.count).map { items.element(boundBy: $0) }.first { ($0.value as? String) != "Üzerinde" }?.identifier)
        app.buttons[pickID].tap()
        XCTAssertEqual(app.buttons[pickID].value as? String, "Üzerinde")
        let changed = avatar.value as? String
        XCTAssertNotEqual(changed, before, "the chosen piece is on the figure")
        app.buttons["trayUndo"].tap()
        XCTAssertEqual(avatar.value as? String, before, "undo restores the previous piece")
        app.buttons["trayDone"].tap()

        app.buttons["primary.newLook"].tap()
        XCTAssertNotEqual(avatar.value as? String, before, "a new prepared look is on the same figure")
        let undo = app.buttons["worldUndo"]
        XCTAssertTrue(undo.waitForExistence(timeout: 3), "a new look offers undo")
        attach(app, "v28-H03-new-look")
        undo.tap()
        XCTAssertEqual(avatar.value as? String, before, "undo brings the previous look back")
    }

    /// v2.8 H04/H05: the city is chosen by hand and kept; rain is only a labelled preview; travel opens
    /// from the city menu.
    func testWorldRainPreviewAndCity() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest"]
        app.launch()
        let chip = app.buttons["weatherChip"]
        XCTAssertTrue(chip.waitForExistence(timeout: 10))
        chip.tap()
        let rain = app.switches["cityRainToggle"]
        XCTAssertTrue(app.reveal(rain), "the rain preview is in the city sheet, below the world streets")
        rain.coordinate(withNormalizedOffset: CGVector(dx: 0.93, dy: 0.5)).tap()
        app.buttons["Bitti"].tap()
        XCTAssertTrue(chip.label.contains("önizlemesi"), "a preview never passes for real weather: \(chip.label)")
        attach(app, "v28-H04-rain-preview")
        chip.tap()
        XCTAssertTrue(app.reveal(app.switches["cityRainToggle"]))
        app.switches["cityRainToggle"].coordinate(withNormalizedOffset: CGVector(dx: 0.93, dy: 0.5)).tap()
        let bcn = app.buttons["city-ES-BCN"]
        for _ in 0..<4 where !(bcn.exists && bcn.isHittable) { app.collectionViews.firstMatch.swipeDown() }
        XCTAssertTrue(bcn.waitForExistence(timeout: 5))
        bcn.tap()
        attach(app, "v28-H04-city-sheet")
        app.buttons["Bitti"].tap()
        XCTAssertTrue(chip.label.contains("Barcelona · Hava verisi yok"), chip.label)
        attach(app, "v28-H04-barcelona")
        chip.tap()
        app.buttons["city-TR-IST"].tap()
        app.buttons["Bitti"].tap()
    }

    /// v2.8 H05 (UI28-T009): an old reading is shown as "Son bilinen tahmin" with its time and is not
    /// drawn as current rain; a live one shows its temperature and source. Labelled test readings.
    func testWeatherFreshnessStates() throws {
        for (fixture, expect) in [("stale", "Son bilinen tahmin"), ("live", "Test verisi")] {
            let app = XCUIApplication()
            app.launchArguments = ["-resetForUITest", "-worldCity", "TR-IST", "-worldWeatherFixture", fixture]
            app.launch()
            let chip = app.buttons["weatherChip"]
            XCTAssertTrue(chip.waitForExistence(timeout: 10))
            XCTAssertTrue(chip.label.contains("İstanbul · 12° · Yağmur"), chip.label)
            XCTAssertTrue(chip.label.contains(expect), chip.label)
            attach(app, "v28-H05-weather-\(fixture)")
            app.terminate()
        }
    }

    /// v2.6/v2.8 D01–D05: Dene is one place for bringing a product and trying it; the camera does not
    /// start until the mirror is opened; photo and link say they are not in this build; the cloud mode
    /// is off; without a camera the mirror says so instead of imitating one.
    func testMirrorEntryAndCameraFallback() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest"]
        app.launch()
        XCTAssertTrue(app.buttons["homeTryOn"].waitForExistence(timeout: 10))
        app.buttons["homeTryOn"].tap()
        XCTAssertTrue(app.tabBars.buttons["Dene"].isSelected)
        let open = app.buttons["primary.openMirror"]
        XCTAssertTrue(open.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["primary.tryOnModel"].exists, "the same selection can go on the 3D model")
        // SCAN-T011: photo intake is live (read on the device); only the store link is still not in this build.
        XCTAssertNotEqual(app.buttons["tryOnPhoto"].value as? String, "Bu sürümde yok")
        XCTAssertEqual(app.buttons["tryOnLink"].value as? String, "Bu sürümde yok")
        XCTAssertEqual(XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.count, 0, "no camera prompt before the user opens the mirror")
        attach(app, "v28-D01-dene")
        for _ in 0..<4 where !open.isHittable { app.swipeUp() }
        open.tap()
        #if targetEnvironment(simulator)
        XCTAssertTrue(app.descendants(matching: .any)["cameraFallbackCard"].waitForExistence(timeout: 5), "no camera, no imitation")
        attach(app, "v28-D04-mirror-fallback")
        #endif
        app.buttons["mirrorClose"].tap()
        XCTAssertTrue(open.waitForExistence(timeout: 5))
    }

    /// UI20-T-007: each tab keeps its route across tab switches and across a visit to Dene.
    func testTabRoutesSurviveTabSwitchAndScan() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest"]
        app.launch()

        XCTAssertTrue(app.buttons["weatherChip"].waitForExistence(timeout: 10))
        app.buttons["weatherChip"].tap()
        XCTAssertTrue(app.buttons["worldPlan"].waitForExistence(timeout: 5))
        app.buttons["worldPlan"].tap()
        XCTAssertTrue(app.buttons["demoTripButton"].waitForExistence(timeout: 10))
        app.buttons["demoTripButton"].tap()
        let tile = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'tripTile-'")).firstMatch
        XCTAssertTrue(tile.waitForExistence(timeout: 10))
        tile.tap()
        let summary = app.staticTexts["capsuleSummary"]
        XCTAssertTrue(summary.waitForExistence(timeout: 10))

        app.tabBars.buttons["Ben"].tap()
        XCTAssertTrue(app.navigationBars["Benim Modelim"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Bugün"].tap()
        XCTAssertTrue(summary.waitForExistence(timeout: 5), "Bugün's route survived a tab switch")

        app.tabBars.buttons["Dene"].tap()
        XCTAssertTrue(app.buttons["mirrorScan"].waitForExistence(timeout: 5))
        app.buttons["mirrorScan"].tap()
        let close = app.buttons["Kapat"]
        XCTAssertTrue(close.waitForExistence(timeout: 5))
        close.tap()
        app.tabBars.buttons["Bugün"].tap()
        XCTAssertTrue(summary.waitForExistence(timeout: 5), "a visit to Dene returns to where the user was")
    }

    /// UI20-T-002 / UI28-T026: at the largest accessibility text size the world still offers its actions, in bounds.
    func testHomeAtAccessibilityTextSize() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["worldAvatar"].waitForExistence(timeout: 10))
        for id in ["primary.newLook", "homeTryOn", "weatherChip"] {
            let b = app.buttons[id]
            XCTAssertTrue(b.isHittable, id)
            XCTAssertLessThanOrEqual(b.frame.maxX, app.frame.maxX + 0.5, "no horizontal overflow: \(id)")
            XCTAssertGreaterThanOrEqual(b.frame.minX, app.frame.minX - 0.5, id)
        }
        attach(app, "v28-home-axxxl")
    }

    /// UI20-WP03: all twenty atoms render; every visible button is at least 44 × 44 pt; light and dark captured.
    func testComponentCatalog() throws {
        for dark in [false, true] {
            XCUIDevice.shared.appearance = dark ? .dark : .light
            let app = XCUIApplication()
            app.launchArguments = ["-resetForUITest", "-componentCatalog"]
            app.launch()
            XCTAssertTrue(app.descendants(matching: .any)["componentCatalog"].waitForExistence(timeout: 10))

            var seen = Set<String>()
            var small: [String] = []
            for i in 1...20 {
                let id = String(format: "K-%03d", i)
                // The stack is not lazy, so off-screen atoms exist too: scroll in steps shorter than the
                // visible area until this one is actually on screen, then check what is visible.
                let header = app.descendants(matching: .any)["catalog-\(id)"]
                for _ in 0..<12 where !(header.exists && header.isHittable && header.frame.minY > 110) {
                    // Drag in the left gutter so the stroke never lands on a slider or the 3D stage.
                    app.coordinate(withNormalizedOffset: CGVector(dx: 0.03, dy: 0.7))
                        .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.03, dy: 0.4)))
                }
                if header.isHittable { seen.insert(id) }
                for button in app.buttons.allElementsBoundByIndex where button.isHittable {
                    let f = button.frame
                    // Navigation bar items are system controls with their own hit area.
                    if f.minY < 100 { continue }
                    if f.height < 43.5 || f.width < 43.5 { small.append("\(button.identifier.isEmpty ? button.label : button.identifier) \(f.size)") }
                }
                if i % 4 == 0 { attach(app, "ui20-catalog-\(dark ? "dark" : "light")-\(id)") }
            }
            XCTAssertEqual(seen.count, 20, "missing: \(Set((1...20).map { String(format: "K-%03d", $0) }).subtracting(seen).sorted())")
            XCTAssertEqual(Set(small), [], "tap targets under 44 pt")
            app.terminate()
        }
        XCUIDevice.shared.appearance = .light
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
