// This file is part of Kpapp for iOS.

import Foundation
import SwiftUI

struct PaymentResultPopUp: View {

    @Environment(\.dismiss) var dismiss
    #if os(iOS)
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    #endif

    let state: State

    enum State {
        case thankYou
        case error
    }

    var body: some View {
        Group {
            #if os(iOS)
            // iPhone Landscape
            if verticalSizeClass == .compact {
                // needs a close button
                closeButton
            }
            #endif
            VStack(spacing: 16) {
                switch state {
                case .thankYou:
                    Text(LocalString.payment_success_title)
                        .font(.title)
                    Text(LocalString.payment_success_description)
                        .font(.headline)
                case .error:
                    Text(LocalString.payment_error_title)
                        .font(.title)
                    Text(LocalString.payment_error_description)
                        .font(.headline)
                }

            }
            .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    var closeButton: some View {
        HStack(alignment: .top) {
            Spacer()
            Button("", systemImage: "x.circle.fill") {
                dismiss()
            }
            .accessibilityIdentifier("close_payment_button")
            .font(.title2)
            .foregroundStyle(.secondary)
            .padding()
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

#Preview {
    PaymentResultPopUp(state: .thankYou)
}
