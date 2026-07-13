// This file is part of Kpapp for iOS.

import SwiftUI

enum UserColorScheme: Int, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    var id: Int {
        rawValue
    }
    
    var name: String {
        switch self {
        case .light: return LocalString.theme_settings_option_light
        case .dark: return LocalString.theme_settings_option_dark
        case .system: return LocalString.theme_settings_option_system
        }
    }
    
    #if os(iOS)
    var asUserInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return .unspecified
        }
    }
    #endif
}

final class UserColorSchemeStore: ObservableObject {
    
    @AppStorage("userColorScheme") var userColorScheme: UserColorScheme = .system {
        didSet {
            update()
        }
    }
    
    #if os(iOS)
    func update() {
        keyWindow?.overrideUserInterfaceStyle = userColorScheme.asUserInterfaceStyle
    }

    private var keyWindow: UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else {
            return nil
        }
        return window
    }
    #endif
}
