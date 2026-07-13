// This file is part of Kpapp for iOS.

import CoreData
import SwiftUI

/// A grid of zim files that are being downloaded.
struct ZimFilesDownloads: View {
    @EnvironmentObject var selection: SelectedZimFileViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DownloadTask.created, ascending: false)],
        animation: .easeInOut
    ) private var downloadTasks: FetchedResults<DownloadTask>
    private let dismiss: (() -> Void)?

    init(dismiss: (() -> Void)?) {
        self.dismiss = dismiss
    }

    var body: some View {
        LazyVGrid(
            columns: ([GridItem(.adaptive(minimum: 250, maximum: 500), spacing: 12)]),
            alignment: .leading,
            spacing: 12
        ) {
            ForEach(downloadTasks.compactMap(\.zimFile)) { zimFile in
                LibraryZimFileContext(
                    content: { DownloadTaskCell(zimFile) },
                    zimFile: zimFile,
                    selection: selection,
                    dismiss: dismiss)
            }
        }
        .modifier(GridCommon())
        .modifier(ToolbarRoleBrowser())
        .navigationTitle(MenuItem.downloads.name)
        .overlay {
            if downloadTasks.isEmpty {
                Message(text: LocalString.zim_file_downloads_overlay_empty_message)
            }
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                if #unavailable(iOS 16), horizontalSizeClass == .regular {
                    Button {
                        NotificationCenter.toggleSidebar()
                    } label: {
                        Label(LocalString.zim_file_downloads_toolbar_show_sidebar_label, systemImage: "sidebar.left")
                    }
                }
            }
            #endif
        }
    }
}
