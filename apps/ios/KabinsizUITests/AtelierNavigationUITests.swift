import XCTest

/// UI20-WP03/WP04 acceptance on the simulator (SIMULATOR_ONLY): navigation contract, the single
/// primary action, no first-launch permission prompts, the honest empty home, and the component catalogue.
final class AtelierNavigationUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    /// UI20-T-006, T-007 (tab bar is navigation only), T-008, T-009.
    func testFirstLaunchHomeAndTabs() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest"]
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["todayHero"].waitForExistence(timeout: 10))
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        XCTAssertEqual(springboard.alerts.count, 0, "UI20-T-008: no permission prompt on first launch")
        XCTAssertEqual(app.alerts.count, 0)

        let tabs = app.tabBars.buttons
        XCTAssertEqual(tabs.count, 3)
        XCTAssertEqual((0..<tabs.count).map { tabs.element(boundBy: $0).label }, ["Bugün", "Dolabım", "Ben"])
        XCTAssertFalse(app.tabBars.buttons["Tara"].exists, "Tara is an action, not a tab")

        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'primary.'")).count, 1, "UI20-T-006: one dominant action on the home screen")
        XCTAssertTrue(app.buttons["primary.createModel"].isHittable, "the home screen's action is to make the model theirs")
        XCTAssertTrue(app.descendants(matching: .any)["heroBody3D"].exists, "the body is the first thing on screen, before any data")
        XCTAssertTrue(app.staticTexts["heroFidelityLabel"].label.contains("kanıtı değildir"))
        // The body fills the top half, so Tara's always-visible door is the toolbar action.
        let scan = app.buttons["scanButton"].firstMatch
        XCTAssertTrue(scan.isHittable, "Tara is reachable without scrolling")  // a system toolbar item: its own hit area
        let quick = app.buttons["scanQuickAction"]
        for _ in 0..<4 where !quick.isHittable { app.swipeUp() }
        XCTAssertTrue(quick.isHittable, "and a visible button further down; the page scrolls over the model")
        XCTAssertGreaterThanOrEqual(quick.frame.height, 44)
        for _ in 0..<4 where !app.buttons["primary.createModel"].isHittable { app.swipeDown() }

        // UI20-T-009: an empty wardrobe is never presented as having pieces.
        for claim in ["parça var", "Dolabından 3", "dolabında var"] {
            XCTAssertEqual(app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", claim)).count, 0, claim)
        }
        attach(app, "ui20-home-empty")

        app.tabBars.buttons["Ben"].tap()
        XCTAssertTrue(app.buttons["createNeutralBody"].waitForExistence(timeout: 5), "the stand-in on the home screen saved nothing")
        app.tabBars.buttons["Bugün"].tap()
        let addFirst = app.buttons["addFirstGarment"]
        for _ in 0..<4 where !addFirst.isHittable { app.swipeUp() }
        addFirst.tap()
        XCTAssertTrue(app.tabBars.buttons["Dolabım"].isSelected, "the empty-state action leads to the wardrobe")
        app.buttons["loadSyntheticCloset"].tap()
        app.tabBars.buttons["Bugün"].tap()
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'parça var'")).firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["syntheticBadge"].firstMatch.exists, "a synthetic wardrobe says so on the home screen")
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'primary.'")).count, 1)
        attach(app, "ui20-home-synthetic-wardrobe")
    }

    /// UI20-T-007: each tab keeps its route across tab switches and across opening and closing Tara.
    func testTabRoutesSurviveTabSwitchAndScan() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest"]
        app.launch()

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

        app.buttons["scanButton"].firstMatch.tap()
        let close = app.buttons["Kapat"]
        XCTAssertTrue(close.waitForExistence(timeout: 5))
        close.tap()
        XCTAssertTrue(summary.waitForExistence(timeout: 5), "closing Tara returns to where the user was")
        XCTAssertTrue(app.tabBars.buttons["Bugün"].isSelected)
    }

    /// UI20-T-002: at the largest accessibility text size the home screen still offers its action.
    func testHomeAtAccessibilityTextSize() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["todayHero"].waitForExistence(timeout: 10))
        let primary = app.buttons["primary.createModel"]
        for _ in 0..<6 where !primary.isHittable { app.swipeUp() }
        XCTAssertTrue(primary.isHittable)
        XCTAssertLessThanOrEqual(primary.frame.maxX, app.frame.maxX + 0.5, "no horizontal overflow")
        XCTAssertGreaterThanOrEqual(primary.frame.minX, app.frame.minX - 0.5)
        attach(app, "ui20-home-axxxl")
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
