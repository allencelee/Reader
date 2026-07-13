// This file is part of Kpapp for iOS.

import SwiftUI

struct Action: View {
    let title: String
    let isDestructive: Bool
    let action: @MainActor () async -> Void

    init(title: String,
         isDestructive: Bool = false,
         action: @MainActor @escaping () async -> Void = {}
    ) {
        self.title = title
        self.isDestructive = isDestructive
        self.action = action
    }

    var body: some View {
        AsyncButton(action: action, label: {
            HStack {
                Spacer()
                Text(title)
                    .fontWeight(.medium)
                    .foregroundColor(isDestructive ? .red : nil)
                Spacer()
            }
        })
    }
}
