// This file is part of Kpapp for iOS.

import Foundation
import SwiftUI

struct AsyncButton<S: View>: View {
    private let action: @MainActor () async -> Void
    private let label: S

    @State private var task: Task<Void, Never>?

    var body: some View {
        Button {
            guard task == nil else {
                return
            }
            task = Task {
                await action()
                task = nil
            }
        } label: {
            if task != nil {
                label
                    .opacity(0.25)
                    .overlay {
                        ProgressView()
                            .controlSize(.small)
                    }
                    .animation(.default, value: true)
            } else {
                label
            }
        }
    }

    init(action: @MainActor @escaping () async -> Void, @ViewBuilder label: @escaping () -> S) {
        self.action = action
        self.label = label()
    }
}

#Preview {
    Group {
        AsyncButton {
            try? await Task.sleep(for: .seconds(3))
        } label: {
            Text("Try me!")
        }
    }.frame(minWidth: 200, minHeight: 400)
}
