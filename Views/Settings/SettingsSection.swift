// This file is part of Kpapp for iOS.

import SwiftUI

struct SettingSection<Content: View>: View {
    let name: String
    let alignment: VerticalAlignment
    let leftWidth: CGFloat
    var content: () -> Content

    init(
        name: String,
        alignment: VerticalAlignment = .firstTextBaseline,
        leftWidth: CGFloat = 100,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.name = name
        self.alignment = alignment
        self.leftWidth = leftWidth
        self.content = content
    }

    var body: some View {
        HStack(alignment: alignment) {
            Text("\(name):").frame(width: leftWidth, alignment: .trailing)
            VStack(alignment: .leading, spacing: 16, content: content)
            Spacer()
        }
    }
}
