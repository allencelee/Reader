// This file is part of Kpapp for iOS.

import Foundation

@MainActor
final class OrderedCache<Key: Hashable, Value> {

    private struct ValueDated<V> {
        let value: V
        let date: Date
    }

    private var dict: [Key: ValueDated<Value>] = [:]

    var count: Int {
        dict.count
    }

    func findBy(key: Key) -> Value? {
        if let dateValue = dict[key] {
            return dateValue.value
        }
        return nil
    }

    func removeAll() {
        dict = [:]
    }

    func removeOlderThan(_ pastDate: Date) {
        dict = dict.filter { (_, value: ValueDated<Value>) in
            value.date >= pastDate
        }
    }

    func removeNotMatchingWith(keys: Set<Key>) -> [Value] {
        let removableKeys = Set(dict.keys).subtracting(keys)
        return removableKeys.compactMap { key in
            dict.removeValue(forKey: key)?.value
        }
    }

    func setValue(_ value: Value, forKey key: Key, dated: Date = Date.now) {
        dict[key] = ValueDated(value: value, date: dated)
    }

    func removeValue(forKey key: Key) {
        dict.removeValue(forKey: key)
    }
}
