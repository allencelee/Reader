// This file is part of Kpapp for iOS.

import SwiftUI

struct OutlineButton: View {
    private let items: [OutlineItem]
    private let itemTree: [OutlineItem]
    private let scrollTo: (_ itemID: String) -> Void
    @Environment(\.dismissSearch) private var dismissSearch
    @State private var isShowingOutline = false
    
    init(browser: BrowserViewModel) {
        items = browser.outlineItems
        itemTree = browser.outlineItemTree
        scrollTo = { [weak browser] itemID in
            browser?.scrollTo(outlineItemID: itemID)
        }
    }
    
    var body: some View {
        Button {
            isShowingOutline = true
        } label: {
            Image(systemName: "list.bullet")
        }
        .disabled(items.isEmpty)
        .help(LocalString.outline_button_outline_help)
        .popover(isPresented: $isShowingOutline) {
            NavigationStack {
                Group {
                    if itemTree.isEmpty {
                        Message(text: LocalString.outline_button_outline_empty_message)
                    } else {
                        List(itemTree, id: \.id) { item in
                            OutlineNode(item: item) { item in
                                scrollTo(item.id)
                                isShowingOutline = false
                                dismissSearch()
                            }
                        }.listStyle(.plain)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            isShowingOutline = false
                        } label: {
                            Text(LocalString.common_button_done).fontWeight(.semibold)
                        }
                    }
                }
            }
            .frame(idealWidth: 360, idealHeight: 600)
            .modifier(MarkAsHalfSheet())
        }
    }

    struct OutlineNode: View {
        @ObservedObject var item: OutlineItem
        let action: ((OutlineItem) -> Void)?

        var body: some View {
            if let children = item.children {
                DisclosureGroup(isExpanded: $item.isExpanded) {
                    ForEach(children) { child in
                        OutlineNode(item: child, action: action)
                    }
                } label: {
                    Button(item.text) { action?(item) }
                }
            } else {
                Button(item.text) { action?(item) }
            }
        }
    }
}
