// This file is part of Kpapp for iOS.

import SwiftUI

struct BadgeModifier: ViewModifier {
    let count: Int
    
    private static let formatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        numberFormatter.usesGroupingSeparator = false
        return numberFormatter
    }()
    
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            HStack {
                if FeatureFlags.hasLibrary, count > 0 {
                    Text(Self.formatter.string(for: count) ?? "")
                        .font(.subheadline)
                        .fontDesign(.monospaced)
                        .frame(minWidth: 18, minHeight: 18)
                        .padding(.horizontal, count > 9 ? 12 : 8)
                        .foregroundColor(.background)
                        .background(Color.accentColor.opacity(0.5))
                        .clipShape(Capsule())
                        .bold()
                }
                content
            }
        }
    }
}
