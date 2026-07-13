// This file is part of Kpapp for iOS.

import SwiftUI

struct MarkAsHalfSheet: ViewModifier {
    func body(content: Content) -> some View {
        content.presentationDetents([.medium, .large])
    }
}

struct ToolbarRoleBrowser: ViewModifier {
    func body(content: Content) -> some View {
        content.toolbarRole(.browser)
    }
}

struct LoadingOverlay: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        if isLoading {
            content
                .overlay(content: {
                    ProgressView()
                })
        } else {
            content
        }
    }
}
