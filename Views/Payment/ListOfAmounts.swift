// This file is part of Kpapp for iOS.

import SwiftUI
import Combine

struct ListOfAmounts: View {
    let amountSelected: PassthroughSubject<SelectedAmount?, Never>

    @Binding public var isMonthly: Bool
    @State private var listState: ListState = .list

    init(amountSelected: PassthroughSubject<SelectedAmount?, Never>, isMonthly: Binding<Bool>) {
        self.amountSelected = amountSelected
        _isMonthly = isMonthly
    }

    var body: some View {
        if case .customAmount = listState {
            CustomAmount(selected: amountSelected, isMonthly: isMonthly)
        } else {
            listing()
            // doesn't need reset, since this is the default state
        }
    }

    private func reset() {
        listState = .list
    }

    private func listing() -> some View {
        let items = isMonthly ? Payment.monthlies : Payment.oneTimes
        let averageText: String = if isMonthly {
            LocalString.payment_selection_average_monthly_donation_subtitle
        } else {
            LocalString.payment_selection_last_year_average_subtitle
        }
        let defaultCurrency: String = Payment.defaultCurrencyCode
        return List {
            ForEach(items) { amount in
                Button(
                    action: {
                        amountSelected.send(
                            SelectedAmount(
                                value: amount.value,
                                currency: defaultCurrency,
                                isMonthly: isMonthly
                            )
                        )
                    },
                    label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(amount.value, format: .currency(code: defaultCurrency))
                            .frame(alignment: .leading)
                        if amount.isAverage {
                            Text(averageText)
                                .foregroundColor(.secondary)
                                .font(.caption2)
                        }
                    }
                })
                .padding(6)
            }
            Button(action: {
                listState = .customAmount
            }, label: {
                Text(LocalString.payment_selection_custom_amount)
            })
            .padding(6)
        }
    }
}

private enum ListState {
    case list
    case customAmount
}

#Preview {
    ListOfAmounts(
        amountSelected: PassthroughSubject<SelectedAmount?, Never>(),
        isMonthly: Binding<Bool>.constant(true)
    )
}
