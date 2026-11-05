import UIKit
import XCTest

/// V37 / ADR-018 §7 (SIMULATOR_ONLY, synthetic fixture): a flat-lay photo with an A4 sheet becomes a
/// garment sewn from its own pattern, with the photo's own print on the front, and the figure on the home
/// world wears it. The fixture is a drawn navy striped T-shirt with a red "KABINSIZ" wordmark (OWNED_ORIGINAL).
final class PhotoGarmentUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    func testPhotoGarmentIsSewnAndWorn() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestVault", "photo-\(UUID().uuidString)", "-photoGarmentFixture"]
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["worldAvatar"].waitForExistence(timeout: 10))

        // Entry: "Kıyafet ekle" → the photo row comes first.
        app.tab("Dolabım")
        let add = app.buttons["addGarment"]
        XCTAssertTrue(add.waitForExistence(timeout: 5))
        add.tap()
        let open = app.buttons["photoGarmentOpen"]
        XCTAssertTrue(open.waitForExistence(timeout: 5))
        open.tap()
        let fixture = app.buttons["photoGarmentFixture"]
        XCTAssertTrue(fixture.waitForExistence(timeout: 5))
        attach(app, "PHOTO-UI-01-intro")
        fixture.tap()

        // Review: the front crop, sizes read against the A4 sheet, the pattern drawn.
        // The list loads lazily: the button at its foot is checked after scrolling to it.
        let front = app.descendants(matching: .any)["photoGarmentFront"]
        XCTAssertTrue(front.waitForExistence(timeout: 40), "the photo is read")
        let apply = app.buttons["photoGarmentApply"]
        let chest = app.staticTexts["photoGarmentSize-CHEST_WIDTH"]
        XCTAssertTrue(chest.exists, "the A4 sheet gives the chest width")
        XCTAssertTrue(chest.label.contains("±"), "with its uncertainty: \(chest.label)")
        let name = app.textFields["photoGarmentName"]
        XCTAssertEqual(name.value as? String, "Lacivert tişört")
        attach(app, "PHOTO-UI-02-review")
        let pattern = app.descendants(matching: .any)["photoGarmentPattern"]
        XCTAssertTrue(app.reveal(pattern))
        attach(app, "PHOTO-UI-03-pattern")
        XCTAssertTrue(app.reveal(apply))
        XCTAssertTrue(apply.isEnabled)
        apply.tap()

        // Saved to the wardrobe.
        let card = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'garment-usr-'")).firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 10), "the garment is in the wardrobe")
        attach(app, "PHOTO-UI-04-wardrobe")

        // Home world: put it on and see it on the figure.
        app.tab("Bugün")
        let avatar = app.descendants(matching: .any)["worldAvatar"]
        XCTAssertTrue(avatar.waitForExistence(timeout: 10))
        sleep(3)
        app.buttons["worldDressUp"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["dressUpTray"].waitForExistence(timeout: 5))
        app.buttons["dressSlot-TOP"].tap()
        let piece = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'dressItem-usr-'")).firstMatch
        XCTAssertTrue(piece.waitForExistence(timeout: 5), "the photo garment is in the tray")
        let on = NSPredicate(format: "value CONTAINS 'Üst: Lacivert tişört'")
        if !on.evaluate(with: avatar) { piece.tap() }
        XCTAssertTrue(wait(avatar, on, timeout: 5), "worn: \(avatar.value as? String ?? "")")
        // Take off what would cover it (the example look's coat and scarf), so the print is in view.
        for slot in ["OUTERWEAR", "OTHER_ACCESSORY"] {
            let tab = app.buttons["dressSlot-\(slot)"]
            guard tab.exists else { continue }
            tab.tap()
            let worn = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'dressItem-' AND value == 'Üzerinde'")).firstMatch
            if worn.waitForExistence(timeout: 2) { worn.tap() }
        }
        app.buttons["dressSlot-TOP"].tap()
        XCTAssertTrue(piece.waitForExistence(timeout: 5))
        sleep(2)
        let wearing = avatar.screenshot().image
        attach(app, "PHOTO-UI-05-worn-front")

        // The sewn garment really changes the drawn figure: take it off and compare.
        piece.tap()
        XCTAssertTrue(wait(avatar, NSPredicate(format: "NOT (value CONTAINS 'Üst: Lacivert tişört')")))
        sleep(2)
        XCTAssertGreaterThan(changedFraction(wearing, avatar.screenshot().image), 0.01, "the photo garment shows on the figure")
        piece.tap()
        XCTAssertTrue(wait(avatar, on, timeout: 5))
        sleep(2)

        // Turned by hand: the back wears the garment's colour (the photo shows the front only).
        let start = avatar.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.55))
        start.press(forDuration: 0.05, thenDragTo: avatar.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.55)))
        sleep(4)
        attach(app, "PHOTO-UI-06-worn-turned")
        app.buttons["dressDone"].tap()
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
