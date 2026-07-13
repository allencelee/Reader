// This file is part of Kpapp for iOS.

import SwiftUI

enum MoveDirection: Sendable {
    
    // swiftlint:disable:next identifier_name
    case up
    case down
    case left
    case right
}

struct MoveCommand: ViewModifier {
    
    private let action: ((MoveDirection) -> Void)?
    
    init(perform action: ((MoveDirection) -> Void)?) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
    }
}
