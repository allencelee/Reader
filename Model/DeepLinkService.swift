// This file is part of Kpapp for iOS.

import Foundation

/// Helper to figure out if a deeplink started ZIM file
/// handling is already running.
/// In that case we do not want to handle the default
/// navigation to the latest opened ZIM file
@MainActor
final class DeepLinkService {
    
    static let shared = DeepLinkService()
    
    private var ids = Set<UUID>()
    
    private init() {}
    
    func startFor(uuid: UUID) {
        ids.insert(uuid)
    }
    
    func stopFor(uuid: UUID) {
        ids.remove(uuid)
    }
    
    func isRunning() -> Bool {
        !ids.isEmpty
    }
}
