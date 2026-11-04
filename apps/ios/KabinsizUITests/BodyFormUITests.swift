import UIKit
import XCTest

/// V36-01 / ADR-017 (SIMULATOR_ONLY): the user picks Kadın / Erkek / Nötr in the body studio. The
/// form changes the drawing and the chest wording, never a value the user set; undo brings the old
/// form back, and the choice survives a relaunch.
final class BodyFormUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    func testBodyFormPickerKeepsValues() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestVault", "form-\(UUID().uuidString)"]
        app.launch()
        app.openProfile()

        // Start screen: the form is picked before the body exists; nothing is preselected for the user.
        let start = app.segmentedControls["startBodyForm"]
        XCTAssertTrue(start.waitForExistence(timeout: 5))
        XCTAssertTrue(start.buttons["Nötr"].isSelected, "neutral until the user picks")
        let standIn = app.descendants(matching: .any)["standIn3D"]
        XCTAssertTrue(standIn.waitForExistence(timeout: 5))
        let neutralDrawn = requireFigure(standIn, "the neutral stand-in")
        let neutralStandIn = standIn.screenshot().pngRepresentation
        start.buttons["Kadın"].tap()
        XCTAssertTrue(wait(standIn, NSPredicate(format: "value CONTAINS 'Kadın başlangıç şekli'")), "the stand-in says which form it shows")
        let picked = app.descendants(matching: .any)["standIn3D"]
        if requireFigure(picked, "the Kadın stand-in"), neutralDrawn {
            sleep(1)
            XCTAssertNotEqual(picked.screenshot().pngRepresentation, neutralStandIn, "the stand-in is drawn in the picked form")
        }
        XCTAssertTrue(start.buttons["Kadın"].isSelected)
        sleep(2)
        attach(app, "BFORM-UI-01-start-picker")
        app.buttons["createNeutralBody"].tap()

        let fidelity = app.staticTexts["bodyFidelityLabel"]
        XCTAssertTrue(fidelity.waitForExistence(timeout: 10))
        XCTAssertEqual(fidelity.label, "3B model, kadın formu. Görünüm, beden uyumunun kanıtı değildir.")
        let model = app.descendants(matching: .any)["body3D"]
        XCTAssertTrue(model.waitForExistence(timeout: 5))
        let feminineDrawn = requireFigure(model, "the feminine body")
        let feminineShot = model.screenshot().pngRepresentation
        attach(app, "BFORM-UI-02-feminine")

        // Type a waist measurement (the strongest promise: a typed value never changes with the form).
        let field = app.textFields["measurementValue"]
        bringIntoView(field, in: app)
        for _ in 0..<3 where (field.value as? String) != "71" {
            field.tap()
            XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
            if let old = field.value as? String, !old.isEmpty, old != field.placeholderValue {
                field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: old.count))
            }
            field.typeText("71")
        }
        XCTAssertEqual(field.value as? String, "71")
        app.buttons["saveMeasurement"].tap()
        let waistValue = app.staticTexts["value-WAIST"]
        let waist = app.sliders["slider-WAIST"]
        bringIntoView(waistValue, in: app, above: true)
        XCTAssertTrue(wait(waistValue, NSPredicate(format: "label == '71 cm'"), timeout: 10))
        XCTAssertFalse(waist.isEnabled, "a typed measurement is locked against stray touches")
        let shapedWaist = waistValue.label
        XCTAssertTrue(app.sliders["Göğüs (büst) çevresi"].exists, "the feminine chest row says bust")

        // Switch to Erkek: proportions change, the shaped waist stays exactly as the user left it.
        let picker = app.segmentedControls["bodyForm"]
        bringIntoView(picker, in: app, above: true)
        waitUntilStill(picker)
        XCTAssertTrue(picker.buttons["Kadın"].isSelected)
        let erkek = picker.buttons["Erkek"]
        erkek.tap()
        XCTAssertTrue(wait(erkek, NSPredicate(format: "isSelected == true"), timeout: 10), "one tap is enough")
        bringIntoView(fidelity, in: app, above: true)
        XCTAssertTrue(wait(fidelity, NSPredicate(format: "label BEGINSWITH '3B model, erkek formu'"), timeout: 10))
        if requireFigure(model, "the masculine body"), feminineDrawn {
            sleep(1)
            XCTAssertNotEqual(feminineShot, model.screenshot().pngRepresentation, "the drawing follows the form")
        }
        attach(app, "BFORM-UI-03-masculine")
        bringIntoView(waistValue, in: app)
        XCTAssertEqual(waistValue.label, shapedWaist, "the form never changes a value the user set")
        XCTAssertFalse(waist.isEnabled, "still the user's typed measurement")
        XCTAssertTrue(app.sliders["Göğüs çevresi"].exists)
        XCTAssertFalse(app.sliders["Göğüs (büst) çevresi"].exists)

        // Undo returns the feminine form; redo brings Erkek back.
        let undo = app.buttons["bodyUndo"]
        bringIntoView(undo, in: app, above: true)
        waitUntilStill(undo)
        XCTAssertTrue(wait(undo, NSPredicate(format: "isEnabled == true"), timeout: 10))
        undo.tap()
        XCTAssertTrue(wait(fidelity, NSPredicate(format: "label BEGINSWITH '3B model, kadın formu'"), timeout: 10), "one tap on undo is enough")
        let redo = app.buttons["bodyRedo"]
        XCTAssertTrue(wait(redo, NSPredicate(format: "isEnabled == true"), timeout: 10))
        redo.tap()
        XCTAssertTrue(wait(fidelity, NSPredicate(format: "label BEGINSWITH '3B model, erkek formu'"), timeout: 10), "one tap on redo is enough")
        let savedForm = "erkek"
        sleep(1)
        app.terminate()

        // Relaunch: the form and the value come back from the encrypted vault.
        app.launch()
        app.openProfile()
        let back = app.staticTexts["bodyFidelityLabel"]
        XCTAssertTrue(back.waitForExistence(timeout: 10))
        XCTAssertTrue(back.label.hasPrefix("3B model, \(savedForm) formu"), "the chosen form survives a relaunch")
        let relaunchedWaist = app.staticTexts["value-WAIST"]
        bringIntoView(relaunchedWaist, in: app)
        XCTAssertEqual(relaunchedWaist.label, shapedWaist)
        attach(app, "BFORM-UI-04-relaunched")

        // A slider drag reaches the slider (it used to be lost in the frozen profile, ADR-016).
        let shoulder = app.sliders["slider-SHOULDER_WIDTH"]
        let shoulderValue = app.staticTexts["value-SHOULDER_WIDTH"]
        bringIntoView(shoulder, in: app, above: true)
        let before = shoulderValue.label
        shoulder.dragThumb(to: 0.85)
        XCTAssertTrue(wait(shoulderValue, NSPredicate(format: "label != %@", before), timeout: 5), "one drag moves the slider")

        // Home dresses the user's body, so it is drawn in the chosen form too.
        app.buttons["profileClose"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["worldAvatar"].waitForExistence(timeout: 10))
        sleep(2)
        attach(app, "BFORM-UI-05-home-follows-form")
    }

    /// Asserts that the figure is drawn, and says whether it was, so a pixel comparison runs only on a
    /// drawn figure. This used to be an expected failure (ADR-016 "Bilinen açık", fixed 2026-11-04).
    @discardableResult
    private func requireFigure(_ element: XCUIElement, _ what: String) -> Bool {
        let drawn = waitForFigure(element)
        XCTAssertTrue(drawn, "\(what) is drawn")
        return drawn
    }

    /// True once the element's centre column holds figure pixels, not only the backdrop gradient.
    /// RealityKit's first frame in a list cell can take seconds on a loaded simulator.
    private func waitForFigure(_ element: XCUIElement, timeout: TimeInterval = 15) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if element.exists, Self.hasFigure(element.screenshot().image) { return true }
            Thread.sleep(forTimeInterval: 0.5)
        } while Date() < deadline
        return false
    }

    /// The backdrop is a smooth vertical gradient, so along the centre column neighbouring rows differ
    /// by very little; the figure's edges and shading make clear jumps. Counts those jumps.
    static func hasFigure(_ image: UIImage) -> Bool {
        guard let cg = image.cgImage else { return false }
        let w = cg.width, h = cg.height
        var px = [UInt8](repeating: 0, count: w * h * 4)
        guard let ctx = CGContext(data: &px, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                                  space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return false }
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
        func lum(_ x: Int, _ y: Int) -> Int { let i = (y * w + x) * 4; return (Int(px[i]) * 3 + Int(px[i + 1]) * 6 + Int(px[i + 2])) / 10 }
        var jumps = 0
        for x in [w / 2 - w / 20, w / 2, w / 2 + w / 20] {
            for y in stride(from: h / 10, to: h * 9 / 10 - 2, by: 2) where abs(lum(x, y) - lum(x, y + 2)) > 6 { jumps += 1 }
        }
        return jumps >= 12   // the ground disc alone gives about 6
    }

    /// Waits until the element's frame is the same twice in a row (the list has stopped moving).
    private func waitUntilStill(_ element: XCUIElement, timeout: TimeInterval = 8) {
        let deadline = Date().addingTimeInterval(timeout)
        var last = element.frame
        while Date() < deadline {
            Thread.sleep(forTimeInterval: 0.4)
            let now = element.frame
            if now == last { return }
            last = now
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
