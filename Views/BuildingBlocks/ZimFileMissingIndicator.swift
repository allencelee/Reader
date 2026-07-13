// This file is part of Kpapp for iOS.

import SwiftUI

struct ZimFileMissingIndicator: View {
    var body: some View {
        Image(systemName: "exclamationmark.triangle.fill")
            .renderingMode(.original)
            .help(LocalString.zim_file_missing_indicator_help)
    }
}
