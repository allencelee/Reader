// This file is part of Kpapp for iOS.

import SwiftUI

/// Add padding around the modified view. On iOS, the padding is adjusted so that the modified view align with the search bar.
struct GridCommon: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    let edges: Edge.Set?

    init(edges: Edge.Set? = nil) {
        self.edges = edges
    }

    func body(content: Content) -> some View {
        GeometryReader { proxy in
            ScrollView {
                content.padding(
                    edges ?? (
                        horizontalSizeClass == .compact || verticalSizeClass == .compact ? [.horizontal, .bottom] : .all
                    ),
                    proxy.size.width > 380 && verticalSizeClass == .regular ? 20 : 16
                )
            }
        }
    }
}

