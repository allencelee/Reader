// This file is part of Kpapp for iOS.

import SwiftUI
import Combine

struct PaymentForm: View {
    let amountSelected: PassthroughSubject<SelectedAmount?, Never>
    @State var isMonthly: Bool = false
    @Environment(\.dismiss) var dismiss

    init(amountSelected: PassthroughSubject<SelectedAmount?, Never>) {
        self.amountSelected = amountSelected
    }

    private func reset() {
        isMonthly = false
    }

    var body: some View {
        #if os(iOS)
        HStack {
            Spacer()
            Text(LocalString.payment_donate_title)
                .font(.title)
                .padding(.init(top: 12, leading: 0, bottom: 8, trailing: 0))
            Spacer()
        }
        .overlay(alignment: .topTrailing) {
            Button("", systemImage: "x.circle.fill") {
                dismiss()
            }
            .accessibilityIdentifier("close_payment_button")
            .font(.title)
            .foregroundStyle(.tertiary)
            .padding()
        }
        #endif

        VStack {
            ListOfAmounts(amountSelected: amountSelected, isMonthly: $isMonthly)
        }
    }
}

#Preview {
    PaymentForm(amountSelected: PassthroughSubject<SelectedAmount?, Never>())
}

struct SelectedAmount {
    let value: Double
    let currency: String
    let isMonthly: Bool

    init(value: Double, currency: String, isMonthly: Bool) {
        // make sure we won't go over Stripe's max amount
        self.value = min(value, Double(StripeKpapp.maxAmount) * 100.0)
        self.currency = currency
        self.isMonthly = isMonthly
    }
}

struct AmountOption: Identifiable {
    // stabelise the scroll, if we have the same amount
    // for both one-time and monthly and we switch in-between them
    let id = UUID()
    let value: Double
    let isAverage: Bool

    init(value: Double, isAverage: Bool = false) {
        self.value = value
        self.isAverage = isAverage
    }
}

final class FormReset: ObservableObject {
    func reset() {
        objectWillChange.send()
    }
}
