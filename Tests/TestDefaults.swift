// This file is part of Kpapp for iOS.

import Foundation
@testable import Kpapp

final class TestDefaults: NSObject, Defaulting {
    
    var dict: [Defaults._AnyKey: AnyObject] = [:]
    
    func setup() {
        self[.categoriesToLanguages] = [:]
        self[.libraryAutoRefresh] = false
        self[.libraryETag] = ""
        self[.libraryUsingOldISOLangCodes] = false
        self[.libraryLanguageCodes] = Set<String>()
    }
    
    subscript<Value>(key: Defaults.Key<Value>) -> Value {
        get {
            // swiftlint:disable:next force_cast
            dict[key] as! Value
        }
        set {
            dict[key] = newValue as AnyObject
        }
    }
}
