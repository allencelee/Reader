// This file is part of Kpapp for iOS.

import SwiftUI

struct AlertHandler: ViewModifier {
    @State private var activeAlert: ActiveAlert?

    private let alert = NotificationCenter.default.publisher(for: .alert)

    func body(content: Content) -> some View {
        content.onReceive(alert) { notification in
            if let alertValue = notification.userInfo?["alert"] as? ActiveAlert {
                activeAlert = alertValue
            }
        }
        .alert(alertText(), isPresented: Binding<Bool>.constant(activeAlert != nil)) {
            Button(LocalString.common_button_ok) {
                activeAlert = nil
            }
        }
    }
        
    private func alertText() -> String {
        switch activeAlert {
        case .articleFailedToLoad:
            LocalString.alert_handler_alert_failed_title
        case .downloadFailed:
            LocalString.download_service_failed_description
        case let .downloadError(code, message):
            LocalString.download_service_error_description(withArgs: "\(code)", message)
        case nil:
            ""
        }
    }
}
