// This file is part of Kpapp for iOS.

import Foundation


public protocol Defaulting: NSObjectProtocol {
    subscript<Value: Defaults.Serializable>(key: Defaults.Key<Value>) -> Value { get set }
}

final class UDefaults: NSObject, Defaulting {
    subscript<Value>(key: Defaults.Key<Value>) -> Value {
        get {
            Defaults[key]
        }
        set {
            Defaults[key] = newValue
        }
    }
}
