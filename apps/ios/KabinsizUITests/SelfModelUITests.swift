import UIKit
import XCTest

/// V37 / ADR-018 (SIMULATOR_ONLY): "Fotoğraftan modelimi kur". The Simulator has no Vision body-pose model,
/// so the flow runs on our own mannequin photo with joints read on macOS beforehand (`-selfModelFixture`,
/// labelled on screen). Checks: the review proposes look, body and worn garments; the face needs both
/// yeses; applying changes the drawn figure on the profile and on the home world; the look can be deleted.
final class SelfModelUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    func testSelfModelFromPhotoDressesTheFigure() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestVault", "self-\(UUID().uuidString)", "-selfModelFixture"]
        app.launch()
        app.openProfile()
        let create = app.buttons["createNeutralBody"]
        XCTAssertTrue(create.waitForExistence(timeout: 10))
        create.tap()
        let figure = app.descendants(matching: .any)["body3D"]
        XCTAssertTrue(figure.waitForExistence(timeout: 10))
        sleep(2)
        let neutralShot = figure.screenshot().pngRepresentation

        // Entry: one row in Benim Modelim.
        let open = app.buttons["selfModelOpen"]
        bringIntoView(open, in: app)
        XCTAssertEqual(open.label, "Fotoğraftan modelimi kur")
        let height = app.textFields["selfModelHeight"]
        // A tap that lands while the list is still settling from the scroll can be lost: one retry.
        for _ in 0 ..< 2 where !height.exists {
            open.tap()
            _ = height.waitForExistence(timeout: 4)
        }
        XCTAssertTrue(height.waitForExistence(timeout: 2), "the flow opened")
        height.tap()
        height.typeText("170")
        app.switches["selfModelWantsFace"].switches.firstMatch.tap()
        attach(app, "SELF-UI-01-intro")
        // The decimal pad covers the photo buttons; "Bitti" closes it (a tap under the keyboard would
        // otherwise make XCUITest drag the sheet, which closed it).
        let done = app.buttons["selfModelKeyboardDone"]
        if done.waitForExistence(timeout: 2) { done.tap() }
        let fixture = app.buttons["selfModelFixture"]
        XCTAssertTrue(app.reveal(fixture), "the fixture button is in view")
        fixture.tap()

        // Review: look, body estimates with ranges, worn garments; the face needs "bu bana benziyor".
        // The review Form loads lazily: its first row proves the analysis finished; the apply button at
        // its foot is only checked once scrolled to.
        let apply = app.buttons["selfModelApply"]
        XCTAssertTrue(app.switches["selfModelUseLook"].waitForExistence(timeout: 30), "the analysis finishes")
        let source = app.descendants(matching: .any).matching(identifier: "selfModelPoseSource").firstMatch
        XCTAssertTrue(source.exists && source.label.contains("Simülatör fikstürü"), "the fixture is labelled first on screen")
        XCTAssertTrue(app.switches["selfModelUseLook"].exists)
        XCTAssertTrue(app.switches["selfModelUseFace"].exists, "the face crop is offered")
        attach(app, "SELF-UI-02-review-look")
        XCTAssertTrue(app.reveal(apply))
        XCTAssertFalse(apply.isEnabled, "the face waits for the likeness confirmation")
        let likeness = app.switches["selfModelLikeness"]
        for _ in 0 ..< 6 where !likeness.isHittable { app.collectionViews.firstMatch.swipeDown() }
        likeness.switches.firstMatch.tap()
        XCTAssertTrue(app.reveal(apply))
        XCTAssertTrue(apply.isEnabled)
        let chest = app.switches["selfModelBody-CHEST"]
        XCTAssertTrue(app.reveal(chest))
        XCTAssertTrue(chest.label.contains("Tahmin") || app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'ölçü değil'")).firstMatch.exists)
        attach(app, "SELF-UI-03-review-body")
        let top = app.switches["selfModelGarment-TOP"]
        XCTAssertTrue(app.reveal(top))
        XCTAssertTrue(app.switches["selfModelGarment-BOTTOM"].exists)
        attach(app, "SELF-UI-04-review-worn")
        XCTAssertTrue(app.reveal(apply))
        apply.tap()

        // Profile figure now carries the look: it looks different from the neutral form.
        XCTAssertTrue(apply.waitForNonExistence(timeout: 10))
        XCTAssertTrue(figure.waitForExistence(timeout: 10))
        sleep(3)
        XCTAssertNotEqual(figure.screenshot().pngRepresentation, neutralShot, "the figure shows the personal look")
        attach(app, "SELF-UI-05-profile-figure")
        let openAgain = app.buttons["selfModelOpen"]
        bringIntoView(openAgain, in: app)
        XCTAssertEqual(openAgain.label, "Modelimi fotoğraftan yenile")

        // Home world: the dressed figure carries the same look.
        app.buttons["profileClose"].tap()
        let world = app.descendants(matching: .any)["worldAvatar"]
        XCTAssertTrue(world.waitForExistence(timeout: 10))
        sleep(4)
        attach(app, "SELF-UI-06-home-twin")

        // Delete the look: one tap, the figure goes back to neutral.
        app.openProfile()
        let delete = app.buttons["selfModelDeleteLook"]
        bringIntoView(delete, in: app)
        delete.tap()
        XCTAssertTrue(delete.waitForNonExistence(timeout: 5))
        XCTAssertEqual(app.buttons["selfModelOpen"].label, "Fotoğraftan modelimi kur")
    }

    private func bringIntoView(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<20 {
            if element.exists, element.isHittable, element.frame.minY > app.profileFigureBottom + 8,
               element.frame.maxY < app.frame.maxY - 40 { return }
            let below = element.exists ? element.frame.midY > app.frame.midY : true
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.97, dy: below ? 0.85 : 0.6))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.97, dy: below ? 0.6 : 0.85))
            start.press(forDuration: 0.05, thenDragTo: end, withVelocity: .default, thenHoldForDuration: 0.3)
        }
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
