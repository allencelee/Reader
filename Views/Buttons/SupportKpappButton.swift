// This file is part of Kpapp for iOS.

import Foundation
import SwiftUI

struct SupportKpappButton: View {

    let openDonation: () -> Void

    var body: some View {
        Button {
            openDonation()
        } label: {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                Text(LocalString.payment_support_button_label)
            }
        }
    }
}
