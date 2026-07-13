// This file is part of Kpapp for iOS.

import SwiftUI

#if os(iOS)
struct ShareButton: View {
    
    let buttonLabel: String = LocalString.common_button_share
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Label {
                Text(buttonLabel)
            }  icon: {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
}
#endif
