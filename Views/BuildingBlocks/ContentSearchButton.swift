// This file is part of Kpapp for iOS.

#if os(iOS)
import SwiftUI
import WebKit

struct ContentSearchButton: View {
    @FocusedValue(\.isBrowserURLSet) var isBrowserURLSet
    let findInteraction: () -> Void
    
    init(browser: BrowserViewModel) {
        findInteraction = { [weak browser] in
            browser?.webView.isFindInteractionEnabled = true
            browser?.webView.findInteraction?.presentFindNavigator(showingReplace: false)
        }
    }

    var body: some View {
        Button(LocalString.common_search,
               systemImage: "text.magnifyingglass",
               action: {
            findInteraction()
        }
        ).disabled(isBrowserURLSet != true)
    }
}
#endif
