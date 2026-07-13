// This file is part of Kpapp for iOS.

import XCTest
@testable import Kpapp

final class OrderedCacheTests: XCTestCase {

    @MainActor
    func testEmpty() {
        let cache = OrderedCache<String, String>()
        XCTAssertEqual(cache.count, 0)
        XCTAssertNil(cache.findBy(key: "not to be found"))
    }

    @MainActor
    func testOneItem() {
        let cache = OrderedCache<String, String>()
        let pastDate = Date.distantPast
        cache.setValue("test_value", forKey: "keyOne", dated: pastDate)
        XCTAssertEqual(cache.count, 1)
        XCTAssertNil(cache.findBy(key: "not to be found"))
        XCTAssertEqual(cache.findBy(key: "keyOne"), "test_value")
        cache.removeOlderThan(pastDate)
        XCTAssertEqual(cache.count, 1)
        cache.removeOlderThan(Date.now)
        XCTAssertEqual(cache.count, 0)
    }

    @MainActor
    func testRemoveOlderThan() {
        let cache = OrderedCache<String, String>()
        let nowDate = Date.now
        cache.setValue("test_value", forKey: "keyOne", dated: nowDate)
        cache.setValue("old_value", forKey: "keyOld", dated: Date.distantPast)
        XCTAssertEqual(cache.count, 2)
        cache.removeOlderThan(nowDate.advanced(by: -1))
        XCTAssertEqual(cache.count, 1)
    }

    @MainActor
    func testRemoveByKey() {
        let cache = OrderedCache<String, Int>()
        cache.setValue(1, forKey: "one")
        cache.setValue(0, forKey: "zero")
        cache.removeValue(forKey: "zero")
        XCTAssertNil(cache.findBy(key: "zero"))
        XCTAssertEqual(cache.findBy(key: "one"), 1)
    }

    @MainActor
    func testRemoveByNotMatchingKeys() {
        let cache = OrderedCache<String, Int>()
        cache.setValue(101, forKey: "one_zero_one")
        cache.setValue(1, forKey: "one")
        cache.setValue(202, forKey: "two_zero_two")
        let removed = cache.removeNotMatchingWith(keys: Set<String>(["some", "one", "else"]))
        XCTAssertEqual(cache.count, 1)
        XCTAssertNil(cache.findBy(key: "zero"))
        XCTAssertEqual(cache.findBy(key: "one"), 1)
        XCTAssertEqual(removed.count, 2)
        XCTAssertTrue(removed.contains(101))
        XCTAssertTrue(removed.contains(202))
    }

}
