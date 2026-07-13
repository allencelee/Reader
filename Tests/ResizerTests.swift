// This file is part of Kpapp for iOS.

import XCTest
@testable import Kpapp

final class ResizerTests: XCTestCase {

    func testLogoWithinFrame() {
        let frame = CGSize(width: 590, height: 410)
        let imageOriginalSize = CGSize(width: 192, height: 140)
        let renderSize = Resizer.fit(imageOriginalSize, into: frame)

        XCTAssertTrue(renderSize.width <= frame.width)
        XCTAssertTrue(renderSize.height <= frame.height)

        XCTAssertTrue(renderSize.width > imageOriginalSize.width)
        XCTAssertTrue(renderSize.height > imageOriginalSize.height)

        XCTAssertEqual(renderSize.ratio, imageOriginalSize.ratio)
    }

}
