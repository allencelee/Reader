// This file is part of Kpapp for iOS.

import SwiftUI

struct ZimFileContextMenu: View {
    let zimFile: ZimFile
    
    var body: some View {
        if zimFile.fileURLBookmark != nil, !zimFile.isMissing {
            Section { ArticleActions(zimFileID: zimFile.fileID) }
        }
        if let downloadURL = zimFile.downloadURL {
            Section {
                Button(LocalString.library_zim_file_context_copy_url) {
                    CopyPaste.copyToPasteBoard(url: downloadURL)
                }
            }
        }
    }
}
