// This file is part of Kpapp for iOS.

import SwiftUI

struct BookmarkButton: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var isShowingPopOver = false
    let articleBookmarked: Bool
    let isButtonDisabled: Bool
    let createBookmark: () -> Void
    let deleteBookmark: () -> Void

    var body: some View {
        Menu {
            if articleBookmarked {
                Button(role: .destructive) {
                    deleteBookmark()
                } label: {
                    Label(LocalString.common_dialog_button_remove_bookmark, systemImage: "star.slash.fill")
                }
            } else {
                Button {
                    createBookmark()
                } label: {
                    Label(LocalString.common_dialog_button_add_bookmark, systemImage: "star")
                }
            }
            Button {
                isShowingPopOver = true
            } label: {
                Label(LocalString.common_dialog_button_show_bookmarks, systemImage: "list.star")
            }
        } label: {
            Label {
                Text(LocalString.common_dialog_button_show_bookmarks)
            } icon: {
                Image(systemName: articleBookmarked ? "star.fill" : "star")
                    .renderingMode(articleBookmarked ? .original : .template)
            }
        } primaryAction: {
            isShowingPopOver = true
        }
        .help(LocalString.bookmark_button_show_help)
        .popover(isPresented: $isShowingPopOver) {
            NavigationStack {
                Bookmarks().navigationBarTitleDisplayMode(.inline).toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            isShowingPopOver = false
                        } label: {
                            Text(LocalString.common_button_done).fontWeight(.semibold)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            if articleBookmarked {
                                deleteBookmark()
                            } else {
                                createBookmark()
                            }
                        } label: {
                            Label {
                                Text(
                                    articleBookmarked ?
                                    LocalString.common_dialog_button_remove_bookmark :
                                        LocalString.common_dialog_button_add_bookmark
                                )
                            } icon: {
                                Image(systemName: articleBookmarked ? "star.fill" : "star")
                                    .renderingMode(articleBookmarked ? .original : .template)
                            }
                        }.disabled(isButtonDisabled)
                    }
                }
            }
            .frame(idealWidth: 360, idealHeight: 600)
            .modifier(MarkAsHalfSheet())
        }
    }
}
