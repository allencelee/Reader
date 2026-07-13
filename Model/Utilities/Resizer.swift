// This file is part of Kpapp for iOS.

import Foundation

enum Resizer {

    static func fit(_ size: CGSize, into maxSize: CGSize) -> CGSize {
        let ratio = size.ratio
        if maxSize.ratio <= ratio {
            // subject is horizontal
            return CGSize(width: maxSize.width, height: maxSize.width / ratio)
        } else {
            return CGSize(width: maxSize.height * ratio, height: maxSize.height)
        }
    }
}

extension CGSize {
    var ratio: CGFloat {
        guard height != 0 else { return 1 }
        return width / height
    }
}
