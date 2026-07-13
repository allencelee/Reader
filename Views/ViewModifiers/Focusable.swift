// This file is part of Kpapp for iOS.

import SwiftUI

struct NotFocusable: ViewModifier {
    
    func body(content: Content) -> some View {
        content
    }
}

struct Focusable<Value: Hashable>: ViewModifier {
    
    private let value: Value
    private let focusState: FocusState<Value>.Binding
    private let onReturn: () -> Void
    private let onDismiss: () -> Void
    
    init(
        _ binding: FocusState<Value>.Binding,
        equals value: Value,
        onReturn: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.focusState = binding
        self.value = value
        self.onReturn = onReturn
        self.onDismiss = onDismiss
    }
    
    func body(content: Content) -> some View {
        content
    }
}
