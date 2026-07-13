// This file is part of Kpapp for iOS.

import Foundation

extension Bundle {
    var isProduction: Bool {
        #if DEBUG
            false
        #else
            appStoreReceiptURL?.path.contains("sandboxReceipt") == true
        #endif
    }
}
