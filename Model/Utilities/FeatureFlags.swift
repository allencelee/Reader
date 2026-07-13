// This file is part of Kpapp for iOS.

import Foundation

enum FeatureFlags {
#if DEBUG
    static let map: Bool = true
#else
    static let map: Bool = false
#endif
    /// Custom apps, which have a bundled zim file, do not require library access
    /// this will remove all library related features
    static let hasLibrary: Bool = !AppType.isCustom

    static let showExternalLinkOptionInSettings: Bool = Config.value(for: .showExternalLinkSettings) ?? true
    static let showSearchSnippetInSettings: Bool = Config.value(for: .showSearchSnippetInSettings) ?? true
}
