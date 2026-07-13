// This file is part of Kpapp for iOS.

import SwiftUI

#if os(iOS)
struct TabsManagerButton: View {
    @EnvironmentObject private var navigation: NavigationViewModel
    @State private var presentedSheet: PresentedSheet?

    private enum PresentedSheet: String, Identifiable {
        var id: String { rawValue }
        case tabsManager
    }

    var body: some View {
        Menu {
            Section {
                Button {
                    navigation.createTab()
                } label: {
                    Label(LocalString.common_tab_menu_new_tab, systemImage: "plus.square")
                }
                Button(role: .destructive) {
                    guard case .tab(let tabID) = navigation.currentItem else { return }
                    navigation.deleteTab(tabID: tabID)
                } label: {
                    Label(LocalString.common_tab_menu_close_this, systemImage: "xmark.square")
                }
                Button(role: .destructive) {
                    navigation.deleteAllTabs()
                } label: {
                    Label(LocalString.common_tab_menu_close_all, systemImage: "xmark.square.fill")
                }
            }
        } label: {
            Label(LocalString.common_tab_manager_title, systemImage: "square.stack")
        } primaryAction: {
            presentedSheet = .tabsManager
        }
        .sheet(item: $presentedSheet) { presentedSheet in
            switch presentedSheet {
            case .tabsManager:
                NavigationStack {
                    TabManager().toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                self.presentedSheet = nil
                            } label: {
                                Text(LocalString.common_button_done).fontWeight(.semibold)
                            }
                        }
                    }
                }
                .modifier(MarkAsHalfSheet())
                .background(.bar)
            }
        }
    }
}

struct TabManager: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @EnvironmentObject private var navigation: NavigationViewModel
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\Tab.created, order: .reverse)],
        predicate: Tab.Predicate.notMissing,
        animation: .easeInOut
    ) private var tabs: FetchedResults<Tab>

    var body: some View {
        List(tabs, id: \.self) { tab in
            Button {
                navigation.currentItem = NavigationItem.tab(objectID: tab.objectID)
            } label: {
                TabLabel(tab: tab)
            }
            .listRowBackground(
                navigation.currentItem == NavigationItem.tab(objectID: tab.objectID) ? Color.blue.opacity(0.2) : nil
            )
            .swipeActions {
                Button(role: .destructive) {
                    navigation.deleteTab(tabID: tab.objectID)
                } label: {
                    Label(LocalString.common_tab_list_close, systemImage: "xmark")
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(LocalString.common_tab_navigation_title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Menu {
                Button(role: .destructive) {
                    guard case let .tab(tabID) = navigation.currentItem else { return }
                    navigation.deleteTab(tabID: tabID)
                } label: {
                    Label(LocalString.common_tab_menu_close_this, systemImage: "xmark.square")
                }
                Button(role: .destructive) {
                    navigation.deleteAllTabs()
                } label: {
                    Label(LocalString.common_tab_menu_close_all, systemImage: "xmark.square.fill")
                }
            } label: {
                Label(LocalString.common_tab_menu_new_tab, systemImage: "plus.square")
            } primaryAction: {
                navigation.createTab()
            }
        }
    }
}
#endif
