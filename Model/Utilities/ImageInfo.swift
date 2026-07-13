// This file is part of Kpapp for iOS.

import Foundation
import SwiftUI

enum ImageInfo {
    static func sizeOf(imageName: String) -> CGSize? {
        guard let cgImage = UIImage(named: imageName)?.cgImage else { return nil }
        return CGSize(width: cgImage.width, height: cgImage.height)
    }
}
