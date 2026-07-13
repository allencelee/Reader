// This file is part of Kpapp for iOS.

import SwiftUI

enum CellBackground {
    private static let normal: Color = .secondaryBackground
    private static let selected: Color = .tertiaryBackground

    
    static func colorFor(isHovering: Bool, isSelected: Bool = false) -> Color {
        isHovering ? selected : normal
    }
    
    static let clipShapeRectangle = RoundedRectangle(cornerRadius: 12, style: .continuous)
    
    static func hotspotSelectionColorFor(isHovering: Bool, isSelected: Bool) -> Color {
        isSelected ? .accentColor.opacity(0.5) : normal
    }
}
