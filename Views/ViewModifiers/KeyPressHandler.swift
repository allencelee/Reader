// This file is part of Kpapp for iOS.

import SwiftUI

struct KeyPressHandler: ViewModifier {
    
    let key: KeyEquivalent
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
    }
    
    @available(macOS 14.0, iOS 17.0, *)
    private func newApi(content: Content) -> some View {
        content.onKeyPress(key, action: {
            Task { await MainActor.run {
                action()
            }}
            return .handled
        })
    }
}
