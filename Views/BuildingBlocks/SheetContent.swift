// This file is part of Kpapp for iOS.

import SwiftUI

struct SheetContent<Content: View>: View {
    @Environment(\.dismiss) private var dismiss

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            content.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text(LocalString.common_button_done).fontWeight(.semibold)
                    }
                }
            }
        }.navigationViewStyle(.stack)
    }
}
