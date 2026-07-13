// This file is part of Kpapp for iOS.

import CoreData
import WebKit
import Combine

@MainActor
final class NavigationViewModel: ObservableObject {
    let uuid = UUID()
    // remained optional due to focusedSceneValue conformance
    @Published var currentItem: NavigationItem? = .loading
    private(set) var showDownloads = PassthroughSubject<Void, Never>()

    // MARK: - Tab Management

    static func makeTab(context: NSManagedObjectContext) -> Tab {
        let tab = Tab(context: context)
        tab.created = Date()
        tab.lastOpened = Date()
        try? context.obtainPermanentIDs(for: [tab])
        try? context.save()
        return tab
    }

    func navigateToMostRecentTab() {
        Task {
            await navigateToMostRecentTabAsync()
        }
    }

    private func navigateToMostRecentTabAsync(
        using context: NSManagedObjectContext = Database.shared.viewContext
    ) async {
        let fetchRequest = Tab.fetchRequestLastOpened()
        let tab = (try? context.fetch(fetchRequest).first) ?? Self.makeTab(context: context)
        await MainActor.run { [weak self] in
            self?.currentItem = NavigationItem.tab(objectID: tab.objectID)
        }
    }

    @discardableResult
    func createTab() -> NSManagedObjectID {
        let context = Database.shared.viewContext
        let tab = Self.makeTab(context: context)
        currentItem = NavigationItem.tab(objectID: tab.objectID)

        return tab.objectID
    }

    @MainActor
    func tabIDFor(url: URL?) -> NSManagedObjectID {
        guard let url,
              let coordinator = Database.shared.viewContext.persistentStoreCoordinator,
              let tabID = coordinator.managedObjectID(forURIRepresentation: url),
              // make sure it's not went missing
              let tab = try? Database.shared.viewContext.existingObject(with: tabID) as? Tab,
              tab.zimFile != nil
        else {
            return createTab()
        }
        return tabID
    }
    
    func deleteTabsWithMissingZimFiles() async {
        await withCheckedContinuation { continuation in
            deleteTabsBy(predicate: Tab.Predicate.zimFileMissing) {
                continuation.resume()
            }
        }
    }
    
    private func deleteTabsBy(predicate: NSPredicate, onComplete: @escaping () -> Void) {
        Database.shared.performBackgroundTask { [weak self] context in
            var tabIDsToClose: [NSManagedObjectID] = []
            let tabsRequest = Tab.fetchRequest(predicate: predicate)
            guard let tabs = try? context.fetch(tabsRequest), !tabs.isEmpty else {
                onComplete()
                return
            }
            for tab in tabs {
                tabIDsToClose.append(tab.objectID)
                context.delete(tab)
                // destroy the BrowserViewModel
                BrowserViewModel.destroyTabById(id: tab.objectID)
            }
            print("NavigationViewModel.deleteTabs by: \(tabIDsToClose)")
            
            if context.hasChanges {
                try? context.save()
            }
            
            // if the currently selected tab was deleted
            if case let .tab(tabID) = self?.currentItem, tabIDsToClose.contains(tabID) {
                Task { [weak self] in
                    await self?.navigateToMostRecentTabAsync(using: context)
                    onComplete()
                }
            } else {
                onComplete()
            }
        }
    }

    /// Delete a single tab, and select another tab
    /// Note: do not use in a loop to delete more than 1 tab
    /// - Parameter tabID: ID of the tab to delete
    func deleteTab(tabID: NSManagedObjectID) {
        let currentItemValue = currentItem
        Database.shared.performBackgroundTask { context in
            let sortByCreation = [NSSortDescriptor(key: "created", ascending: false)]
            guard let tabs: [Tab] = try? context.fetch(Tab.fetchRequest(predicate: Tab.Predicate.notMissing,
                                                                        sortDescriptors: sortByCreation)),
                  let tab: Tab = tabs.first(where: { $0.objectID == tabID }) else {
                return
            }
            let newlySelectedTab: Tab?
            if case let .tab(selectedTabID) = currentItemValue, selectedTabID == tabID {
                // select a closeBy tab if the currently selected tab is to be deleted
                newlySelectedTab = tabs.closeBy(toWhere: { $0.objectID == tabID }) ?? Self.makeTab(context: context)
            } else if tabs.count == 1 {
                // we are deleting the last tab and the selection is somewhere else
                newlySelectedTab = Self.makeTab(context: context)
            } else {
                newlySelectedTab = nil // the current selection should remain
            }
            
            // destroy the BrowserViewModel
            BrowserViewModel.destroyTabById(id: tabID)

            // delete tab
            context.delete(tab)
            try? context.save()

            // update selection if needed
            if let newlySelectedTab {
                Task {
                    await MainActor.run {
                        self.currentItem = NavigationItem.tab(objectID: newlySelectedTab.objectID)
                    }
                }
            }
        }
    }

    /// Delete all tabs, and open a new tab
    func deleteAllTabs() {
        Database.shared.performBackgroundTask { [weak self] context in
            // delete all existing tabs
            let tabs = try? context.fetch(Tab.fetchRequest())
            tabs?.forEach {
                // destroy the BrowserViewModel
                BrowserViewModel.destroyTabById(id: $0.objectID)
                context.delete($0)
            }
            
            // create new tab via navigateToMostRecent fallback
            Task { [weak self] in
                await self?.navigateToMostRecentTabAsync(using: context)
            }
        }
    }
}

extension Array {

    /// Return an element close to the one defined in the where callback,
    /// either the one before or if this is the first, the one after
    /// - Parameter toWhere: similar role as in find(where: ) closure, this element is never returned
    /// - Returns: the element before or the one after, never the one that matches by toWhere:
    func closeBy(toWhere whereCallback: @escaping (Element) -> Bool) -> Element? {
        var previous: Element?
        var returnNext: Bool = false
        for element in self {
            if returnNext {
                return element
            }
            if whereCallback(element) {
                if let previous {
                    return previous
                } else {
                    returnNext = true
                }
            } else {
                previous = element
            }
        }
        return previous
    }
}
