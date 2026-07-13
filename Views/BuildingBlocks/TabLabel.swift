// This file is part of Kpapp for iOS.

import SwiftUI

#if os(iOS)
struct TabLabel: View {
    @ObservedObject var tab: Tab

    var body: some View {
        if let zimFile = tab.zimFile, let category = Category(rawValue: zimFile.category) {
            Label {
                Text(tab.title ?? LocalString.common_tab_menu_new_tab).lineLimit(1)
            } icon: {
                Favicon(category: category, imageData: zimFile.faviconData).frame(width: 22, height: 22)
            }
        } else {
            Label(tab.title ?? LocalString.common_tab_menu_new_tab, systemImage: "square")
        }
    }
}
#endif
