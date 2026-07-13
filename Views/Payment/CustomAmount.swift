// This file is part of Kpapp for iOS.

import SwiftUI
import Combine

struct CustomAmount: View {
    private let selected: PassthroughSubject<SelectedAmount?, Never>
    private let isMonthly: Bool
    @State private var customAmount: Double?
    @State private var customCurrency: String = Payment.defaultCurrencyCode
    @FocusState private var focusedField: FocusedField?
    private var currencies = Payment.currencyCodes

    public init(selected: PassthroughSubject<SelectedAmount?, Never>, isMonthly: Bool) {
        self.selected = selected
        self.isMonthly = isMonthly
    }

    var body: some View {
        VStack {
            Spacer()
            List {
                HStack {
                    TextField(LocalString.payment_textfield_custom_amount_label,
                              value: $customAmount,
                              format: .number.precision(.fractionLength(2)))
                    .focused($focusedField, equals: .customAmount)
#if os(iOS)
                    .padding(6)
                    .keyboardType(.decimalPad)
#else
                    .textFieldStyle(.plain)
                    .fontWeight(.bold)
                    .font(Font.headline)
                    .padding(4)
                    .border(Color.accentColor.opacity(0.618), width: 2)
#endif
                    Picker("", selection: $customCurrency) {
                        ForEach(currencies, id: \.self) {
                            Text(Locale.current.localizedString(forCurrencyCode: $0) ?? $0)
                        }
                    }
                }
            }.frame(maxHeight: 100)
            Spacer()
            HStack {
                Spacer()
                Button {
                    if let customAmount {
                        selected.send(
                            SelectedAmount(
                                value: customAmount,
                                currency: customCurrency,
                                isMonthly: isMonthly
                            )
                        )
                    }
                } label: {
                    Text(LocalString.payment_confirm_button_title)
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .padding()
                .disabled( !Payment.isInValidRange(amount: customAmount) )
            }
            Spacer()
        }
        .task { @MainActor in
            focusedField = .customAmount
        }
    }

}

private enum FocusedField: String {
    case customAmount
}

#Preview {
    CustomAmount(selected: PassthroughSubject<SelectedAmount?, Never>(), isMonthly: true)
}
