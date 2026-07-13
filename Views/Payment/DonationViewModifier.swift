// This file is part of Kpapp for iOS.

#if os(iOS)
import SwiftUI
import Combine

struct DonationViewModifier: ViewModifier {
    
    enum DonationPopupState {
        case selection
        case selectedAmount(SelectedAmount)
        case thankYou
        case error
    }
    private let openDonations = NotificationCenter.default.publisher(for: .openDonations)
    private var amountSelected = PassthroughSubject<SelectedAmount?, Never>()
    @State private var showDonationPopUp: Bool = false
    @State private var donationPopUpState: DonationPopupState = .selection
    
    // swiftlint:disable:next function_body_length
    func body(content: Content) -> some View {
        content
            .onReceive(openDonations) { _ in
                showDonationPopUp = true
            }
            .sheet(isPresented: $showDonationPopUp, onDismiss: {
                let result = Payment.showResult()
                switch result {
                case .none:
                    // reset
                    donationPopUpState = .selection
                    return
                case .some(let finalResult):
                    Task {
                        // we need to close the sheet in order to dismiss ApplePay,
                        // and we need to re-open it again with a delay to show thank you state
                        // Swift UI cannot yet handle multiple sheets
                        try? await Task.sleep(for: .milliseconds(100))
                        await MainActor.run {
                            switch finalResult {
                            case .thankYou:
                                donationPopUpState = .thankYou
                            case .error:
                                donationPopUpState = .error
                            }
                            showDonationPopUp = true
                        }
                    }
                }
            }, content: {
                Group {
                    switch donationPopUpState {
                    case .selection:
                        PaymentForm(amountSelected: amountSelected)
                            .presentationDetents([.fraction(0.65)])
                    case .selectedAmount(let selectedAmount):
                        PaymentSummary(selectedAmount: selectedAmount, onComplete: {
                            showDonationPopUp = false
                        })
                        .presentationDetents([.fraction(0.65)])
                    case .thankYou:
                        PaymentResultPopUp(state: .thankYou)
                            .presentationDetents([.fraction(0.33)])
                    case .error:
                        PaymentResultPopUp(state: .error)
                            .presentationDetents([.fraction(0.33)])
                    }
                }
                .onReceive(amountSelected) { value in
                    if let amount = value {
                        donationPopUpState = .selectedAmount(amount)
                    } else {
                        donationPopUpState = .selection
                    }
                }
            })
    }
}
#endif
