// This file is part of Kpapp for iOS.

import SwiftUI
import Network

struct HotspotExplanation: View {
    
    var body: some View {
        VStack {
            HStack {
                Text(Hotspot.explanationText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                Spacer()
            }
            Spacer()
        }
    }
}
