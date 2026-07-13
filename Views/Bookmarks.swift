// This file is part of Kpapp for iOS.

import SwiftUI

struct Bookmarks: View {
    @EnvironmentObject private var navigation: NavigationViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.managedObjectContext) private var managedObjectContext
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.created, order: .reverse)],
        predicate: Bookmarks.buildPredicate(searchText: ""),
        animation: .easeInOut
    ) private var bookmarks: FetchedResults<Bookmark>
    @State private var searchText = ""

    var body: some View {
        LazyVGrid(columns: ([gridItem]), spacing: 12) {
            ForEach(bookmarks, id: \.self) { bookmark in
                Button {
                    NotificationCenter.openURL(bookmark.articleURL)
                    if horizontalSizeClass == .compact {
                        dismiss()
                    }
                } label: {
                    ArticleCell(bookmark: bookmark)
                }
                .buttonStyle(.plain)
                .modifier(BookmarkContextMenu(bookmark: bookmark))
            }
        }
        .modifier(GridCommon())
        .modifier(ToolbarRoleBrowser())
        .navigationTitle(LocalString.bookmark_navigation_title)
        .searchable(text: $searchText, prompt: LocalString.common_search)
        .onChange(of: searchText) { searchText in
            bookmarks.nsPredicate = Bookmarks.buildPredicate(searchText: searchText)
        }
        .overlay {
            if bookmarks.isEmpty {
                Message(text: LocalString.bookmark_overlay_empty_title)
            }
        }
#if os(iOS)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if #unavailable(iOS 16), horizontalSizeClass == .regular {
                    Button {
                        NotificationCenter.toggleSidebar()
                    } label: {
                        Label(LocalString.bookmark_toolbar_show_sidebar_label, systemImage: "sidebar.left")
                    }
                }
            }
        }
#endif
    }

    private var gridItem: GridItem {
        GridItem(.adaptive(minimum: 250, maximum: 500), spacing: 12)
    }

    private static func buildPredicate(searchText: String) -> NSPredicate? {
        let searchPredicate: NSPredicate? = if searchText.isEmpty {
            nil
        } else {
            NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            searchPredicate,
            NSPredicate(format: "zimFile.isMissing == false")
        ].compactMap { $0 })
    }
}
