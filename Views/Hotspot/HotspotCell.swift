// This file is part of Kpapp for iOS.

import SwiftUI

struct HotspotCell<Content: View>: View {
    
    private let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(CellBackground.hotspotSelectionColorFor(isHovering: false, isSelected: false))
            .clipShape(CellBackground.clipShapeRectangle)
    }
    
}
