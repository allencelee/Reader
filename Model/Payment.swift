// This file is part of Kpapp for iOS.

import Foundation
import PassKit
import SwiftUI
import Combine
import os


struct Payment {

    enum FinalResult {
        case thankYou
        case error
    }

    /// Decides if the Thank You / Error pop up should be shown
    /// - Returns: `FinalResult` only once
    @MainActor
    static func showResult() -> FinalResult? {
        // make sure `true` is "read only once"
        let value = Self.finalResult
        Self.finalResult = nil
        return value
    }
    @MainActor
    static private var finalResult: Payment.FinalResult?

    let completeSubject = PassthroughSubject<Void, Never>()

    static let kpappPaymentServer = URL(string: "https://api.donation.kpapp.com/v1/stripe")!
    static let merchantSessionURL = URL(string: "https://apple-pay-gateway.apple.com" )!
    static let merchantId = "merchant.com.utility.kiwireaderut"
    static let paymentSubscriptionManagingURL = "https://www.kpapp.com"
    static let supportedNetworks: [PKPaymentNetwork] = [
        .amex,
        .bancomat,
        .bancontact,
        .cartesBancaires,
        .chinaUnionPay,
        .dankort,
        .discover,
        .eftpos,
        .electron,
        .elo,
        .girocard,
        .interac,
        .idCredit,
        .JCB,
        .mada,
        .maestro,
        .masterCard,
        .mir,
        .privateLabel,
        .quicPay,
        .suica,
        .visa,
        .vPay
    ]
    static let capabilities: PKMerchantCapability = .threeDSecure

    /// NOTE: consider that these currencies support double precision, eg: 5.25 USD.
    /// Revisit `SelectedAmount`, and `SelectedPaymentAmount`
    /// before adding a zero-decimal currency such as: ¥100
    static let currencyCodes = ["USD", "EUR", "CHF"]
    static let defaultCurrencyCode = "USD"
    private static let minimumAmount: Double = 5
    /// The Sripe `amount` value supports up to eight digits
    /// (e.g., a value of 99999999 for a USD charge of $999,999.99).
    /// see: https://docs.stripe.com/api/payment_intents/object#payment_intent_object-amount
    static let maximumAmount: Int = 99999999
    static func isInValidRange(amount: Double?) -> Bool {
        guard let amount else { return false }
        return minimumAmount <= amount && amount <= Double(maximumAmount)*100.0
    }

    static let oneTimes: [AmountOption] = [
        .init(value: 10),
        .init(value: 34, isAverage: true),
        .init(value: 50)
    ]

    static let monthlies: [AmountOption] = [
        .init(value: 5),
        .init(value: 8, isAverage: true),
        .init(value: 10)
    ]

    /// Checks Apple Pay capabilities, and returns the button label accordingly
    /// - Returns: Setup button if no cards added yet,
    /// nil if Apple Pay is not supported
    /// or donation button, if all is OK
    static func paymentButtonType() -> PayWithApplePayButtonLabel? {
        // only app is supporting donations atm.
        guard case .kpapp = AppType.current else { return nil }
        
        if PKPaymentAuthorizationController.canMakePayments() {
            return PayWithApplePayButtonLabel.donate
        }
        if PKPaymentAuthorizationController.canMakePayments(
            usingNetworks: Payment.supportedNetworks,
            capabilities: Payment.capabilities) {
            return PayWithApplePayButtonLabel.setUp
        }
        return nil
    }
    
    /// Async version of ``paymentButtonType()`` with low priority
    /// - Returns: Setup button if no cards added yet,
    /// nil if Apple Pay is not supported
    /// or donation button, if all is OK
    static func paymentButtonTypeAsync() async -> PayWithApplePayButtonLabel? {
        let task = Task<PayWithApplePayButtonLabel?, Never>(priority: .low) {
            Self.paymentButtonType()
        }
        guard let buttonLabel = await task.result.get() else {
            return nil
        }
        return buttonLabel
    }

    func donationRequest(for selectedAmount: SelectedAmount) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = Self.merchantId
        request.merchantCapabilities = Self.capabilities
        request.countryCode = "CH"
        request.currencyCode = selectedAmount.currency
        request.supportedNetworks = Self.supportedNetworks
        request.requiredBillingContactFields = [.emailAddress]
        let recurring: PKRecurringPaymentRequest? = if selectedAmount.isMonthly {
            PKRecurringPaymentRequest(paymentDescription: LocalString.payment_description_label,
                                      regularBilling: .init(label: LocalString.payment_monthly_support_label,
                                                            amount: NSDecimalNumber(value: selectedAmount.value),
                                                            type: .final),
                                      managementURL: URL(string: Self.paymentSubscriptionManagingURL)!)
        } else {
            nil
        }
        request.recurringPaymentRequest = recurring
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(
                label: LocalString.payment_summary_title,
                amount: NSDecimalNumber(value: selectedAmount.value),
                type: .final
            )
        ]
        return request
    }

    func onPaymentAuthPhase(selectedAmount: SelectedAmount,
                            phase: PayWithApplePayButtonPaymentAuthorizationPhase) {
        switch phase {
        case .willAuthorize:
            Log.Payment.info("onPaymentAuthPhase: .willAuthorize")
        case .didAuthorize(let payment, let resultHandler):
            Log.Payment.info("onPaymentAuthPhase: .didAuthorize")
            // call our server to get payment / setup intent and return the client.secret
            Task { @MainActor [resultHandler] in
                let paymentServer = StripeKpapp(endPoint: Self.kpappPaymentServer,
                                                payment: payment)
                do {
                    let publicKey = try await paymentServer.publishableKey()
                    StripeAPI.defaultPublishableKey = publicKey
                } catch let serverError {
                    Self.finalResult = .error
                    resultHandler(.init(status: .failure, errors: [serverError]))
                    return
                }
                // we should update the return path for confirmations
                let stripe = StripeApplePaySimple()
                let result = await stripe.complete(payment: payment,
                                                   returnURLPath: nil,
                                                   usingClientSecretProvider: {
                    await paymentServer.clientSecretForPayment(selectedAmount: selectedAmount)
                })
                // calling any UI refreshing state / subject from here
                // will block the UI in the payment state forever
                // therefore it's defered via static finalResult
                switch result.status {
                case .success:
                    Self.finalResult = .thankYou
                case .failure:
                    Self.finalResult = .error
                default:
                    Self.finalResult = nil
                }
                resultHandler(result)
                Log.Payment.info("onPaymentAuthPhase: .didAuthorize: \(result.status == .success, privacy: .public)")
            }
        case .didFinish:
            Log.Payment.info("onPaymentAuthPhase: .didFinish")
            completeSubject.send(())
        @unknown default:
            Log.Payment.error("onPaymentAuthPhase: @unknown default")
        }

    }

    @available(macOS 13.0, *)
    func onMerchantSessionUpdate() async -> PKPaymentRequestMerchantSessionUpdate {
        guard let session = await StripeKpapp.stripeSession(endPoint: Self.kpappPaymentServer) else {
            await MainActor.run {
                Self.finalResult = .error
            }
            return .init(status: .failure, merchantSession: nil)
        }
        return .init(status: .success, merchantSession: session)
    }
}

private enum MerchantSessionError: Error {
    case invalidStatus
}
