// This file is part of Kpapp for iOS.

import SwiftUI


struct ExternalLinkHandler: ViewModifier {
    @State private var isAlertPresented = false
    @State private var activeAlert: ActiveAlert?
    @Binding var externalURL: URL?

    enum ActiveAlert {
        case ask(url: URL)
        case notLoading
    }

    enum ActiveSheet: Hashable, Identifiable {
        var id: Int { hashValue }
        case safari(url: URL)
    }

    func body(content: Content) -> some View {
        content.onChange(of: externalURL) { url in
            guard let url else { return }
            switch Defaults[.externalLinkLoadingPolicy] {
            case .alwaysAsk:
                isAlertPresented = true
                activeAlert = .ask(url: url)
            case .alwaysLoad:
                load(url: url)
            case .neverLoad:
                isAlertPresented = true
                activeAlert = .notLoading
            }
        }
        .alert(LocalString.external_link_handler_alert_title,
               isPresented: $isAlertPresented,
               presenting: activeAlert) { alert in
            if case .ask(let url) = alert {
                Button(LocalString.external_link_handler_alert_button_load_link) {
                    load(url: url)
                    externalURL = nil // important to nil out, so the same link tapped will trigger onChange again
                }
                Button(LocalString.common_button_cancel, role: .cancel) {
                    externalURL = nil // important to nil out, so the same link tapped will trigger onChange again
                }
            }
        } message: { alert in
            switch alert {
            case .ask:
                Text(LocalString.external_link_handler_alert_ask_description)
            case .notLoading:
                Text(LocalString.external_link_handler_alert_not_loading_description)
            }
        }
    }

    private func load(url: URL) {
        UIApplication.shared.open(url)
    }
}
