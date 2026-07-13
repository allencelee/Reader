// This file is part of Kpapp for iOS.

import SwiftUI
import UniformTypeIdentifiers


/// Tabbed library view on iOS & iPadOS
struct Library: View {
    @EnvironmentObject private var viewModel: LibraryViewModel
    @EnvironmentObject private var navigation: NavigationViewModel
    @State private var tabItem: LibraryTabItem
    @Default(.hasSeenCategories) private var hasSeenCategories
    private let categories: [Category]
    let dismiss: (() -> Void)?

    init(
        dismiss: (() -> Void)?,
        tabItem: LibraryTabItem = .categories,
        categories: [Category] = CategoriesToLanguages().allCategories()
    ) {
        self.dismiss = dismiss
        self.tabItem = tabItem
        self.categories = categories
    }

    var body: some View {
        TabView(selection: $tabItem) {
            ForEach(LibraryTabItem.allCases) { tabItem in
                SheetContent {
                    switch tabItem {
                    case .categories:
                        List(categories) { category in
                            NavigationLink {
                                ZimFilesCategory(category: .constant(category), dismiss: dismiss)
                                    .navigationTitle(category.name)
                                    .navigationBarTitleDisplayMode(.inline)
                            } label: {
                                HStack {
                                    Favicon(category: category).frame(height: 26)
                                    Text(category.name)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .navigationTitle(MenuItem.categories.name)
                    case .opened:
                        ZimFilesOpenedNavStack(dismiss: dismiss)
                    case .downloads:
                        ZimFilesDownloads(dismiss: dismiss)
                            .environment(\.managedObjectContext, Database.shared.viewContext)
                    case .new:
                        ZimFilesNew(dismiss: dismiss)
                    case .hotspot:
                        HotspotZimFilesSelection()
                    }
                }
                .tag(tabItem)
                .tabItem { Label(tabItem.name, systemImage: tabItem.icon) }
            }
        }.onAppear {
            viewModel.start(isUserInitiated: false)
        }.onDisappear {
            hasSeenCategories = true
        }.onReceive(navigation.showDownloads) { _ in
            if tabItem != .downloads {
                tabItem = .downloads
            }
        }
    }
}

@available(iOS 16.0, *)
struct Library_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            Library(dismiss: nil)
                .environmentObject(LibraryViewModel())
                .environment(\.managedObjectContext, Database.shared.viewContext)
        }
    }
}


/// Cross platform, only multi-selection is supported
struct MultiZimFilesSelectionContext<Content: View>: View {
    @ObservedObject var selection: MultiSelectedZimFilesViewModel
    
    private let content: Content
    private let zimFile: ZimFile
    
    init(
        @ViewBuilder content: () -> Content,
        zimFile: ZimFile,
        selection: MultiSelectedZimFilesViewModel
    ) {
        self.content = content()
        self.zimFile = zimFile
        self.selection = selection
    }
    
    var body: some View {
        Group {
            content
                .onTapGesture(perform: {
                    selection.toggleMultiSelect(of: zimFile)
                })
        }.contextMenu {
            ZimFileContextMenu(zimFile: zimFile)
        }
    }
}

/// On macOS, makes the content view clickable, to select a single ZIM file
/// On iOS, converts the modified view to a NavigationLink that goes to the zim file detail.
struct LibraryZimFileContext<Content: View>: View {
    @ObservedObject var selection: SelectedZimFileViewModel
    private let content: Content
    private let zimFile: ZimFile
    /// iOS only
    private let dismiss: (() -> Void)?
    
    init(
        @ViewBuilder content: () -> Content,
        zimFile: ZimFile,
        selection: SelectedZimFileViewModel,
        dismiss: (() -> Void)? = nil
    ) {
        self.content = content()
        self.zimFile = zimFile
        self.selection = selection
        self.dismiss = dismiss
    }
    
    var body: some View {
        Group {
            NavigationLink {
                ZimFileDetail(zimFile: zimFile, dismissParent: dismiss)
            } label: {
                content
            } .accessibilityIdentifier(zimFile.name)
        }.contextMenu {
            ZimFileContextMenu(zimFile: zimFile)
        }
    }
}
