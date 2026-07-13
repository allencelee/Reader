// This file is part of Kpapp for iOS.

import SwiftUI

struct ArticleActions: View {
    
    let zimFileID: UUID
    
    var body: some View {
        AsyncButton {
            guard let url = await ZimFileService.shared.getMainPageURL(zimFileID: zimFileID) else { return }
            NotificationCenter.openURL(url, inNewTab: true)
        } label: {
            Label(LocalString.library_zim_file_context_main_page_label, systemImage: "house")
        }
        if !Brand.hideRandomButton {
            AsyncButton {
                guard let url = await ZimFileService.shared.getRandomPageURL(zimFileID: zimFileID) else { return }
                NotificationCenter.openURL(url, inNewTab: true)
            } label: {
                Label(LocalString.library_zim_file_context_random_label, systemImage: "die.face.5")
            }
        }
    }
}
