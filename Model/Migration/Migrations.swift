// This file is part of Kpapp for iOS.

import Foundation

enum Migrations {
    
    /// A central place for all migrations
    /// they will be executed in the order specified here
    static let all: [Migration] = [
        Self.schemeToZIM(using: Database.shared.viewContext)
    ]
}
