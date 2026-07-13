// This file is part of Kpapp for iOS.

import Foundation
import SwiftUI

struct AsyncButtonView<S: View>: View {
    private let action: @MainActor () async -> Void
    private let label: S
    private let loading: S

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
                loading
            } else {
                label
            }
        }
    }

    init(action: @MainActor @escaping () async -> Void,
         @ViewBuilder label: @escaping () -> S,
         @ViewBuilder loading: @escaping () -> S) {
        self.action = action
        self.label = label()
        self.loading = loading()
    }
}
