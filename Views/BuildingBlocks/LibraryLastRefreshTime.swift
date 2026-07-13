// This file is part of Kpapp for iOS.

import SwiftUI


struct LibraryLastRefreshTime: View {
    @Default(.libraryLastRefresh) private var lastRefresh

    var body: some View {
        if let lastRefresh = lastRefresh {
            if Date().timeIntervalSince(lastRefresh) < 120 {
                Text(LocalString.library_refresh_time_last)
            } else {
                Text(RelativeDateTimeFormatter().localizedString(for: lastRefresh, relativeTo: Date()))
            }
        } else {
            Text(LocalString.library_refresh_time_never)
        }
    }
}
