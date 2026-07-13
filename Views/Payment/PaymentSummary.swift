// This file is part of Kpapp for iOS.

import SwiftUI
import PassKit
import Combine

struct PaymentSummary: View {

    @Environment(\.dismiss) var dismiss

    private let selectedAmount: SelectedAmount
    private let payment: Payment
    private let onComplete: @MainActor () -> Void

    init(selectedAmount: SelectedAmount,
         onComplete: @escaping @MainActor () -> Void) {
        self.selectedAmount = selectedAmount
        self.onComplete = onComplete
        payment = Payment()
    }

    var body: some View {
        VStack {
            Text(LocalString.payment_summary_page_title)
                .font(.largeTitle)
                .padding()
            if selectedAmount.isMonthly {
                Text(LocalString.payment_selection_option_monthly).font(.title)
                    .padding()
            } else {
                Text(LocalString.payment_selection_option_one_time).font(.title)
                    .padding()
            }
            Text(selectedAmount.value.formatted(.currency(code: selectedAmount.currency))).font(.title).bold()
            if let buttonLabel = Payment.paymentButtonType() {
                PayWithApplePayButton(
                    buttonLabel,
                    request: payment.donationRequest(for: selectedAmount),
                    onPaymentAuthorizationChange: { phase in
                        payment.onPaymentAuthPhase(selectedAmount: selectedAmount,
                                                   phase: phase)
                    },
                    onMerchantSessionRequested: payment.onMerchantSessionUpdate
                )
                .frame(width: 186, height: 44)
                .padding()
            } else {
                Text(LocalString.payment_support_fallback_message)
                    .foregroundStyle(.red)
                    .font(.callout)
            }
        }.onReceive(payment.completeSubject) {
            onComplete()
        }
    }
}

#Preview {
    PaymentSummary(
        selectedAmount: SelectedAmount(value: 34,
                                       currency: "CHF",
                                       isMonthly: true),
        onComplete: {}
    )
}
