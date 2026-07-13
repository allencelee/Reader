// This file is part of Kpapp for iOS.

import SwiftUI

#if os(iOS)

/// Backward compatible spacer for toolbar
struct SpacerBackCompatible: View {
    var body: some View {
        if #available(iOS 26, *) {
            EmptyView()
        } else {
            Spacer()
        }
    }
}
#else
struct SpacerBackCompatible: View {
    var body: some View {
        Spacer()
    }
}
#endif
