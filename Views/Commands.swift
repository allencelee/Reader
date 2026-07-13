// This file is part of Kpapp for iOS.

import SwiftUI


struct BrowserViewModelKey: FocusedValueKey {
    typealias Value = BrowserViewModel
}

struct IsBrowserURLSet: FocusedValueKey {
    typealias Value = Bool
}

struct BrowserURL: FocusedValueKey {
    typealias Value = URL
}

struct CanGoBackKey: FocusedValueKey {
    typealias Value = Bool
}

struct CanGoForwardKey: FocusedValueKey {
    typealias Value = Bool
}

struct NavigationItemKey: FocusedValueKey {
    typealias Value = Binding<NavigationItem?>
}

struct HasZIMFilesKey: FocusedValueKey {
    typealias Value = Bool
}

extension FocusedValues {
    
    var hasZIMFiles: HasZIMFilesKey.Value? {
        get { self[HasZIMFilesKey.self] }
        set { self[HasZIMFilesKey.self] = newValue }
    }
    
    var isBrowserURLSet: IsBrowserURLSet.Value? {
        get { self[IsBrowserURLSet.self] }
        set { self[IsBrowserURLSet.self] = newValue }
    }

    var canGoBack: CanGoBackKey.Value? {
        get { self[CanGoBackKey.self] }
        set { self[CanGoBackKey.self] = newValue }
    }

    var canGoForward: CanGoForwardKey.Value? {
        get { self[CanGoForwardKey.self] }
        set { self[CanGoForwardKey.self] = newValue }
    }

    var navigationItem: NavigationItemKey.Value? {
        get { self[NavigationItemKey.self] }
        set { self[NavigationItemKey.self] = newValue }
    }
}

struct NavigationCommands: View {
    let goBack: () -> Void
    let goForward: () -> Void
    @FocusedValue(\.canGoBack) var canGoBack: Bool?
    @FocusedValue(\.canGoForward) var canGoForward: Bool?

    var body: some View {
        Button(LocalString.common_button_go_back) { goBack() }
            .keyboardShortcut("[")
            .disabled(canGoBack != true)
        Button(LocalString.common_button_go_forward) { goForward() }
            .keyboardShortcut("]")
            .disabled(canGoForward != true)
    }
}

struct PageZoomCommands: View {
    @Default(.webViewPageZoom) var webViewPageZoom
    @FocusedValue(\.isBrowserURLSet) var isBrowserURLSet: Bool?

    var body: some View {
        Button(LocalString.commands_button_actual_size) { webViewPageZoom = 1 }
            .keyboardShortcut("0")
            .disabled(webViewPageZoom == 1 || isBrowserURLSet != true)
        Button(LocalString.comments_button_zoom_in) { webViewPageZoom += 0.1 }
            .keyboardShortcut("+")
            .disabled(webViewPageZoom >= 2 || isBrowserURLSet != true)
        Button(LocalString.comments_button_zoom_out) { webViewPageZoom -= 0.1 }
            .keyboardShortcut("-")
            .disabled(webViewPageZoom <= 0.5 || isBrowserURLSet != true)
    }
}
