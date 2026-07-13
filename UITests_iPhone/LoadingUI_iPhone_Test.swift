// This file is part of Kpapp for iOS.

import XCTest

final class LoadingUI_iPhone_Test: XCTestCase {

    @MainActor
    func testLaunchingApp_onIPhone() throws {
        if !XCUIDevice.shared.orientation.isPortrait {
            XCUIDevice.shared.orientation = .portrait
        }
        
        let app = XCUIApplication()
        app.activate()
        let categoriesButton = app.buttons["Categories"]
        Wait.inApp(app, forElement: categoriesButton)
        XCTAssertTrue(categoriesButton.isSelected)
        
        app.buttons["New"].tap()
        app.buttons["Downloads"].tap()
        app.buttons["Opened"].tap()
        categoriesButton.tap()
        app.buttons["Done"].tap()
        
        XCTAssertFalse(app.buttons["Go Back"].isEnabled)
        XCTAssertFalse(app.buttons["Go Forward"].isEnabled)
        XCTAssertFalse(app.buttons["Share"].isEnabled)
        XCTAssertFalse(app.buttons["List"].isEnabled)
        XCTAssertFalse(app.buttons["Random Page"].isEnabled)
    }
}
