import XCTest

extension XCUIApplication {
    /// SwiftUI `List` rows load lazily: a row below the fold does not exist until scrolled to. Swipes the
    /// front-most list up until `element` exists and can be tapped, then returns whether it can.
    @discardableResult
    func reveal(_ element: XCUIElement, maxSwipes: Int = 6) -> Bool {
        if element.waitForExistence(timeout: 2), element.isHittable { return true }
        for _ in 0..<maxSwipes {
            let list = collectionViews.firstMatch
            if list.exists { list.swipeUp() } else { swipeUp() }
            if element.exists, element.isHittable { return true }
        }
        return element.exists && element.isHittable
    }
}

extension XCUIApplication {
    /// v3.2 V32-UI-01: three tabs. Switching tab first closes the profile cover if it is open.
    func tab(_ name: String) {
        let close = buttons["profileClose"]
        if close.exists, close.isHittable { close.tap(); _ = close.waitForNonExistence(timeout: 3) }
        tabBars.buttons[name].tap()
    }

    /// "Ben" is no longer a tab: it opens from the profile button at the top right of each tab.
    func openProfile() {
        let button = buttons.matching(identifier: "openProfile").firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 10), "profile button at the top right")
        button.tap()
        XCTAssertTrue(buttons["profileClose"].waitForExistence(timeout: 5), "profile opened")
    }
}
