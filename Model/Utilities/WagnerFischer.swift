// This file is part of Kpapp for iOS.

import Foundation

enum WagnerFischer {

    static func distance(_ valueA: String.SubSequence, _ valueB: String.SubSequence) -> Int {
        let empty = [Int](repeating: 0, count: valueB.count)
        var last = [Int](0...valueB.count)

        for (indexA, charA) in valueA.enumerated() {
            var current = [indexA + 1] + empty
            for (indexB, charB) in valueB.enumerated() {
                let currentDistance: Int
                if charA == charB {
                    currentDistance = last[indexB]
                } else {
                    currentDistance = min(last[indexB], last[indexB + 1], current[indexB]) + 1
                }
                current[indexB + 1] = currentDistance
            }
            last = current
        }
        return last.last!
    }
}
