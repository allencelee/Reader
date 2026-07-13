// This file is part of Kpapp for iOS.

import SwiftUI

struct NavigationButtons: View {
    let goBack: () -> Void
    let goForward: () -> Void
    @Environment(\.dismissSearch) private var dismissSearch
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @FocusedValue(\.canGoBack) private var canGoBack: Bool?
    @FocusedValue(\.canGoForward) private var canGoForward: Bool?

    var body: some View {
        goBackButton
        if canGoForward == true {
            SpacerBackCompatible()
            goForwardButton
        }
    }

    var goBackButton: some View {
        Button {
            goBack()
            dismissSearch()
        } label: {
            Label(LocalString.common_button_go_back, systemImage: "chevron.left")
        }.disabled(canGoBack != true)
    }

    var goForwardButton: some View {
        Button {
            goForward()
            dismissSearch()
        } label: {
            Label(LocalString.common_button_go_forward, systemImage: "chevron.right")
        }
    }
}
