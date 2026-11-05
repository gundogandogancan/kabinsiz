import XCTest

/// ADR-011: gender, height and weight in the start form (all optional, neutral by default), then the
/// same choices in the body studio. Choosing redraws the body; estimated values say they are not
/// measurements. Also guards the Ben-tab 3D view, which once stayed blank right after creating a body.
final class BodyTemplateUITests: XCTestCase {
    func testGenderHeightWeight() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest"]
        app.launch()
        app.tabBars.buttons["Ben"].tap()

        // Start form: neutral selected, nothing required.
        let gender = app.segmentedControls["startGender"]
        XCTAssertTrue(gender.waitForExistence(timeout: 10))
        XCTAssertTrue(gender.buttons["Nötr"].isSelected, "neutral is the default")
        gender.buttons["Kadın"].tap()
        let height = app.textFields["startHeight"]
        reveal(height, in: app)
        height.tap()
        height.typeText("165")
        let weight = app.textFields["startWeight"]
        weight.tap()
        weight.typeText("60")
        app.buttons["keyboardDone"].tap()
        benShot(app, "0-start-female-165-60")

        let create = app.buttons["createNeutralBody"]
        reveal(create, in: app)
        XCTAssertTrue(create.isEnabled)
        create.tap()

        // The studio opens with the choices kept.
        let picker = app.segmentedControls["bodyTemplate"]
        XCTAssertTrue(picker.waitForExistence(timeout: 10))
        XCTAssertTrue(picker.buttons["Kadın"].isSelected)
        let fidelity = app.staticTexts["bodyFidelityLabel"]
        XCTAssertTrue(fidelity.waitForExistence(timeout: 10))
        XCTAssertEqual(fidelity.label, "3B model (kadın). Görünüm, beden uyumunun kanıtı değildir.")
        // Straight after creating: the Ben tab must already draw the body (was blank until a tab switch).
        for _ in 0..<6 where !app.otherElements["body3D"].exists { app.swipeDown() }
        benShot(app, "1-ben-after-create")

        reveal(picker, in: app)
        picker.buttons["Erkek"].tap()
        XCTAssertTrue(waitFor(fidelity, label: "3B model (erkek). Görünüm, beden uyumunun kanıtı değildir."))
        shot(app, "2-male-165-60")

        // Undo returns to the female body.
        let undo = app.buttons["bodyUndo"]
        for _ in 0..<6 where !(undo.exists && undo.isHittable) { app.swipeDown() }
        undo.tap()
        XCTAssertTrue(waitFor(fidelity, label: "3B model (kadın). Görünüm, beden uyumunun kanıtı değildir."))
    }

    /// An out-of-range entry disables the button and says why; clearing it makes the form valid again.
    func testStartFormRefusesOutOfRange() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest"]
        app.launch()
        app.tabBars.buttons["Ben"].tap()
        let weight = app.textFields["startWeight"]
        XCTAssertTrue(weight.waitForExistence(timeout: 10))
        reveal(weight, in: app)
        weight.tap()
        weight.typeText("400")
        XCTAssertTrue(app.staticTexts["startInvalid"].waitForExistence(timeout: 5))
        app.buttons["keyboardDone"].tap()
        let create = app.buttons["createNeutralBody"]
        reveal(create, in: app)
        XCTAssertFalse(create.isEnabled)
    }

    private func waitFor(_ element: XCUIElement, label: String) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "label == %@", label), object: element)
        return XCTWaiter.wait(for: [expectation], timeout: 10) == .completed
    }

    private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<6 where !element.isHittable { app.swipeUp() }
    }

    /// Screenshot of the Ben tab as it is. `BODY_SHOT_PAUSE` seconds let the 3D view settle;
    /// `BODY_SHOT_DIR` also writes the PNGs there.
    private func benShot(_ app: XCUIApplication, _ name: String) {
        sleep(ProcessInfo.processInfo.environment["BODY_SHOT_PAUSE"].flatMap(UInt32.init) ?? 1)
        keep(app.screenshot(), name)
    }

    /// Screenshot of the saved body on the home screen (its hero draws the saved body), then back.
    private func shot(_ app: XCUIApplication, _ name: String) {
        app.tabBars.buttons["Bugün"].tap()
        sleep(ProcessInfo.processInfo.environment["BODY_SHOT_PAUSE"].flatMap(UInt32.init) ?? 1)
        keep(app.screenshot(), name)
        app.tabBars.buttons["Ben"].tap()
    }

    private func keep(_ image: XCUIScreenshot, _ name: String) {
        let attachment = XCTAttachment(screenshot: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        if let dir = ProcessInfo.processInfo.environment["BODY_SHOT_DIR"] {
            try? image.pngRepresentation.write(to: URL(fileURLWithPath: dir).appendingPathComponent("\(name).png"))
        }
    }
}
