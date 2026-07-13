// This file is part of Kpapp for iOS.

#if os(iOS)
import SwiftUI

struct MoreTabButton: View {
    
    @ObservedObject var browser: BrowserViewModel
    @FocusedValue(\.hasZIMFiles) var hasZimFiles
    
    /// For custom apps, that have a dedicated hotspot toolbar button
    let presentHotspot: () -> Void
    
    @State private var menuPopOver = false
    
    var body: some View {
        if Brand.hideRandomButton && Brand.hideShareButton && FeatureFlags.hasLibrary {
            bookmarkButton()
        } else {
            withPopOverForMoreButtons()
        }
    }
    
    @ViewBuilder
    private func withPopOverForMoreButtons() -> some View {
        Button {
            menuPopOver = true
        } label: {
            Image(systemName: "ellipsis")
        }.popover(isPresented: $menuPopOver,
                  attachmentAnchor: .rect(.rect(CGRect(x: 0, y: 0, width: 184, height: 184)))
        ) {
            HStack(spacing: 24) {
                if !Brand.hideRandomButton {
                    randomButton()
                }
                if !Brand.hideShareButton {
                    shareButton()
                }
                if !FeatureFlags.hasLibrary {
                    hotspotButton()
                }
                bookmarkButton()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .tint(.primary)
            .padding(24)
            .presentationCompactAdaptation(.popover)
        }
    }
    
    @ViewBuilder
    private func randomButton() -> some View {
        Button(LocalString.article_shortcut_random_button_title_ios,
               systemImage: "die.face.5",
               action: { [weak browser] in browser?.loadRandomArticle() })
        .disabled(hasZimFiles == false)
    }
    
    @ViewBuilder
    private func shareButton() -> some View {
        ExportButton(
            webViewURL: browser.webView.url,
            pageDataWithExtension: browser.pageDataWithExtension,
            isButtonDisabled: browser.zimFileName.isEmpty,
            actionCallback: {
                menuPopOver = false
            }
        )
    }
    
    @ViewBuilder
    private func hotspotButton() -> some View {
        Button(
            LocalString.enum_navigation_item_hotspot,
            systemImage: "wifi",
            action: {
                menuPopOver = false
                presentHotspot()
            })
    }
    
    @ViewBuilder
    private func bookmarkButton() -> some View {
        BookmarkButton(articleBookmarked: browser.articleBookmarked,
                       isButtonDisabled: browser.zimFileName.isEmpty,
                       createBookmark: { [weak browser] in browser?.createBookmark() },
                       deleteBookmark: { [weak browser] in browser?.deleteBookmark() })
    }
    
}
#endif
