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
