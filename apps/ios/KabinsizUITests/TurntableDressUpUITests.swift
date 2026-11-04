import CoreGraphics
import ImageIO
import XCTest

/// ADR-016 on the simulator (SIMULATOR_ONLY): the figure never moves by itself; only the hand turns
/// it (1:1 drag, flick that comes to rest, "Önden" back to the front); dress-up adds and takes off
/// pieces by tap, undo/redo and drag-and-drop onto the figure.
final class TurntableDressUpUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    private func launch() -> (XCUIApplication, XCUIElement) {
        let app = XCUIApplication()
        app.launchArguments = ["-resetForUITest"]
        app.launch()
        let avatar = app.descendants(matching: .any)["worldAvatar"]
        XCTAssertTrue(avatar.waitForExistence(timeout: 10))
        sleep(4) // street and figure loaded
        return (app, avatar)
    }

    /// TURN-UI01/02: nothing moves while nobody touches it; a drag turns it; after the flick has come
    /// to rest it is still again; "Önden" brings it back to face the user.
    func testFigureMovesOnlyByHand() throws {
        let (app, avatar) = launch()
        let a = avatar.screenshot().image, b = { sleep(3); return avatar.screenshot().image }()
        XCTAssertLessThan(changedFraction(a, b), 0.002, "the figure and the street stand still on their own")
        XCTAssertFalse(app.buttons["worldFaceFront"].exists)

        let before = avatar.screenshot().image
        let start = avatar.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.55))
        start.press(forDuration: 0.05, thenDragTo: avatar.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.55)))
        let front = app.buttons["worldFaceFront"]
        XCTAssertTrue(front.waitForExistence(timeout: 5), "turned by hand")
        let turned = front.value as? String ?? ""
        XCTAssertNotEqual(turned, "0°")
        sleep(4) // any flick has come to rest
        let c = avatar.screenshot().image, d = { sleep(2); return avatar.screenshot().image }()
        XCTAssertLessThan(changedFraction(c, d), 0.002, "after the hand lets go it comes to rest and stays")
        XCTAssertGreaterThan(changedFraction(before, d), 0.01, "the drawn figure really turned, not only the value")
        attach(app, "ADR16-turned-by-hand")

        front.tap()
        XCTAssertTrue(front.waitForNonExistence(timeout: 5), "back to the front")
        sleep(1)
        XCTAssertGreaterThan(changedFraction(d, avatar.screenshot().image), 0.01, "turned back on screen")
        attach(app, "ADR16-front")
    }

    /// TURN-UI03: while the profile cover is up the home world leaves the hierarchy (it starved the
    /// cover's sliders when it kept rendering); closing the cover brings back the same figure, in the
    /// same turned pose, without reloading the street.
    func testWorldComesBackAfterProfileCover() throws {
        let (app, avatar) = launch()
        let start = avatar.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.55))
        start.press(forDuration: 0.05, thenDragTo: avatar.coordinate(withNormalizedOffset: CGVector(dx: 0.6, dy: 0.55)))
        sleep(4) // any flick has come to rest
        let angle = app.buttons["worldFaceFront"].value as? String
        let before = avatar.screenshot().image

        app.openProfile()
        XCTAssertTrue(app.navigationBars["Benim Modelim"].waitForExistence(timeout: 5))
        app.buttons["profileClose"].tap()
        XCTAssertTrue(avatar.waitForExistence(timeout: 5))
        sleep(2)
        XCTAssertEqual(app.buttons["worldFaceFront"].value as? String, angle, "the same turned pose")
        XCTAssertLessThan(changedFraction(before, avatar.screenshot().image), 0.02, "the same figure and street are back")
        attach(app, "ADR16-back-from-profile")
    }

    /// DRESS-UI01..03: tap to put on and take off (even the top), undo/redo, drop a piece on the figure.
    func testDressUpAddsAndRemovesLikeAGame() throws {
        let (app, avatar) = launch()
        app.buttons["worldDressUp"].tap()
        let tray = app.descendants(matching: .any)["dressUpTray"]
        XCTAssertTrue(tray.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["primary.newLook"].exists, "the tray replaces the footer")
        attach(app, "ADR16-dress-up-tray")

        // DRESS-UI00: the tray opens on the outermost layer; taking the coat off is visible at once.
        if app.buttons["dressSlot-OUTERWEAR"].isSelected {
            let coat = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'dressItem-' AND value == 'Üzerinde'")).firstMatch
            XCTAssertTrue(coat.waitForExistence(timeout: 5))
            let dressed = avatar.screenshot().image
            coat.tap()
            XCTAssertTrue(wait(avatar, NSPredicate(format: "NOT (value CONTAINS 'Dış giyim:')")), "the coat came off")
            sleep(1)
            XCTAssertGreaterThan(changedFraction(dressed, avatar.screenshot().image), 0.01, "taking the coat off shows on the figure")
            attach(app, "ADR16-coat-off")
            app.buttons["dressUndo"].tap()
            XCTAssertTrue(wait(avatar, NSPredicate(format: "value CONTAINS 'Dış giyim:'")), "undo puts the coat back")
        }

        app.buttons["dressSlot-TOP"].tap()
        let worn = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'dressItem-' AND value == 'Üzerinde'")).firstMatch
        XCTAssertTrue(worn.waitForExistence(timeout: 5))
        worn.tap()
        XCTAssertTrue(wait(avatar, NSPredicate(format: "NOT (value CONTAINS 'Üst:')")), "the top came off")
        attach(app, "ADR16-top-off")
        app.buttons["dressUndo"].tap()
        XCTAssertTrue(wait(avatar, NSPredicate(format: "value CONTAINS 'Üst:'")), "undo puts it back")
        app.buttons["dressRedo"].tap()
        XCTAssertTrue(wait(avatar, NSPredicate(format: "NOT (value CONTAINS 'Üst:')")), "redo takes it off again")

        // Drag a piece from the tray and drop it on the figure.
        let piece = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'dressItem-'")).element(boundBy: 0)
        XCTAssertTrue(piece.exists)
        let name = piece.label
        let dropped = NSPredicate(format: "value CONTAINS %@", "Üst: \(name)")
        // A long press starts the system drag session; under a loaded simulator the first press can
        // end before the session lifts the piece, so a second, longer press is allowed.
        for hold in [0.8, 1.4] where !dropped.evaluate(with: avatar) {
            piece.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                .press(forDuration: hold, thenDragTo: avatar.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.4)))
            _ = wait(avatar, dropped, timeout: 4)
        }
        XCTAssertTrue(wait(avatar, dropped, timeout: 2), "dropped on the figure: \(name)")
        attach(app, "ADR16-dropped-on-figure")

        // Take off shoes too, then finish.
        app.buttons["dressSlot-FOOTWEAR"].tap()
        let shoes = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'dressItem-' AND value == 'Üzerinde'")).firstMatch
        if shoes.waitForExistence(timeout: 3) {
            shoes.tap()
            XCTAssertTrue(wait(avatar, NSPredicate(format: "NOT (value CONTAINS 'Ayakkabı:')")))
        }
        app.buttons["dressDone"].tap()
        XCTAssertTrue(app.buttons["worldDressUp"].waitForExistence(timeout: 5))
    }

    // MARK: Helpers

    private func wait(_ element: XCUIElement, _ predicate: NSPredicate, timeout: TimeInterval = 5) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if predicate.evaluate(with: element) { return true }
            Thread.sleep(forTimeInterval: 0.25)
        }
        return predicate.evaluate(with: element)
    }

    /// Share of pixels whose colour moved by more than a small step between two screenshots.
    private func changedFraction(_ a: UIImage, _ b: UIImage) -> Double {
        guard let x = rgba(a), let y = rgba(b), x.count == y.count, !x.isEmpty else { return 1 }
        var changed = 0
        for i in stride(from: 0, to: x.count, by: 4) {
            let d = abs(Int(x[i]) - Int(y[i])) + abs(Int(x[i + 1]) - Int(y[i + 1])) + abs(Int(x[i + 2]) - Int(y[i + 2]))
            if d > 24 { changed += 1 }
        }
        return Double(changed) / Double(x.count / 4)
    }

    private func rgba(_ image: UIImage) -> [UInt8]? {
        guard let cg = image.cgImage else { return nil }
        let w = cg.width, h = cg.height
        var data = [UInt8](repeating: 0, count: w * h * 4)
        guard let ctx = CGContext(data: &data, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                                  space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
        return data
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
