// This file is part of Kpapp for iOS.

import Foundation
#if os(iOS)
import UIKit
#endif

enum Device {
    case mac
    case iPhone
    case iPad

    public static var current: Self {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad: return iPad
        case .phone: return iPhone
        default:
            assertionFailure("unrecognised device type: \(UIDevice.current)")
            return iPhone
        }
    }
}
