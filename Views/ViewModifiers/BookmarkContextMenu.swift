/*
 * This file is part of Kpapp for iOS.
*/

import SwiftUI

struct BookmarkContextMenu: ViewModifier {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @EnvironmentObject private var navigation: NavigationViewModel

    let bookmark: Bookmark

    func body(content: Content) -> some View {
        content.contextMenu {
            Button {
                NotificationCenter.openURL(bookmark.articleURL)
            } label: {
                Label(LocalString.bookmark_context_menu_view_title, systemImage: "doc.richtext")
            }
            Button(role: .destructive) {
                managedObjectContext.delete(bookmark)
                try? managedObjectContext.save()
            } label: {
                Label(LocalString.bookmark_context_menu_remove_title, systemImage: "star.slash.fill")
            }
        }
    }
}
