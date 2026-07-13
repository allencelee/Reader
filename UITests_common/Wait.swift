// This file is part of Kpapp for iOS.

import Foundation
import XCTest

struct Wait {
    
    private static let sec30: TimeInterval = 30
    private static func actionFor(_ element: XCUIElement) -> String {
        "waiting for: \(element)"
    }
    
    @discardableResult
    static func inApp(
        _ app: XCUIApplication,
        forElement element: XCUIElement,
        timeout: TimeInterval = sec30
    ) -> XCUIApplication {
        XCTContext.runActivity(named: Self.actionFor(element)) { activity in
            XCTAssertTrue(element.waitForExistence(timeout: timeout), activity.name)
            return app
        }
    }
}
