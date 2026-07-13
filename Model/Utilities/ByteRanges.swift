// This file is part of Kpapp for iOS.

import Foundation

enum ByteRanges {

    static func rangesFor(contentLength: UInt, rangeSize size: UInt, start: UInt = 0) -> [ClosedRange<UInt>] {
        guard size > 0 else {
            return []
        }
        let end = start + contentLength
        return stride(from: start, to: end, by: UInt.Stride(size)).map { point in
            let endOfRange = min(end - 1, point + size - 1)
            return point...endOfRange
        }
    }
}
