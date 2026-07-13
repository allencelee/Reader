// This file is part of Kpapp for iOS.

import SwiftUI
import Combine


/// Displays a grid of available local ZIM files. Used on new tab.
struct LocalLibraryList: View {
    private let load: (URL) -> Void
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Bookmark.created, ascending: false)],
        animation: .easeInOut
    ) private var bookmarks: FetchedResults<Bookmark>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ZimFile.size, ascending: false)],
        predicate: ZimFile.openedPredicate,
        animation: .easeInOut
    ) private var zimFiles: FetchedResults<ZimFile>
    
    init(browser: BrowserViewModel) {
        load = browser.load(url:)
    }

    var body: some View {
        LazyVGrid(
            columns: ([GridItem(.adaptive(minimum: 250, maximum: 500), spacing: 12)]),
            alignment: .leading,
            spacing: 12
        ) {
            GridSection(title: LocalString.welcome_main_page_title) {
                ForEach(zimFiles) { zimFile in
                    AsyncButtonView {
                        guard let url = await ZimFileService.shared
                            .getMainPageURL(zimFileID: zimFile.fileID) else { return }
                        load(url)
                    } label: {
                        ZimFileCell(zimFile, prominent: .name, isSelected: false)
                    } loading: {
                        ZimFileCell(zimFile, prominent: .name, isSelected: true, isLoading: true)
                    }
                    .buttonStyle(.plain)
                }
            }
            if !bookmarks.isEmpty {
                GridSection(title: LocalString.welcome_grid_bookmarks_title) {
                    ForEach(bookmarks.prefix(6)) { bookmark in
                        Button {
                            load(bookmark.articleURL)
                        } label: {
                            ArticleCell(bookmark: bookmark)
                        }
                        .buttonStyle(.plain)
                        .modifier(BookmarkContextMenu(bookmark: bookmark))
                    }
                }
            }
        }.modifier(GridCommon(edges: .all))
    }
}
