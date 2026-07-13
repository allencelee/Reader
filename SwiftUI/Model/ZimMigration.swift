// This file is part of Kpapp for iOS.

//
//  ZimMigration.swift

import Foundation
import CoreData

enum ZimMigration {

    /// Holds the new zimfile host:
    /// Set during migration,
    /// and read back when updating URLS mapped from WebView interaction state,
    /// witch is saved as Data for each opened Tab
    @MainActor private static var newHost: String?
    private static let sortDescriptors = [NSSortDescriptor(keyPath: \ZimFile.created, ascending: true)]
    private static let requestLatestZimFile = ZimFile.fetchRequest(
        predicate: ZimFile.Predicate.isDownloaded,
        sortDescriptors: Self.sortDescriptors
    )

    static func forCustomApps() {
        guard FeatureFlags.hasLibrary == false else { return }
        Database.shared.performBackgroundTask { context in
            guard var zimFiles = try? requestLatestZimFile.execute(),
                  zimFiles.count > 1,
                  let latest = zimFiles.popLast() else {
                return
            }

            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            for zimFile in zimFiles {
                migrateFrom(zimFile: zimFile, toZimFile: latest, using: context)
            }
        }
    }

    /// Migrates the bookmars from an old to new zim file,
    /// also updates the bookmark urls accordingly (based on the new zim id as the host of those URLs)
    /// deletes the old zim file in the DB
    private static func migrateFrom(
        zimFile fromZim: ZimFile,
        toZimFile toZim: ZimFile,
        using context: NSManagedObjectContext
    ) {
        let newHost = toZim.fileID.uuidString
        Task {
            await MainActor.run {
                Self.newHost = newHost
            }
        }
        fromZim.bookmarks.forEach { (bookmark: Bookmark) in
            bookmark.zimFile = toZim
            if let newArticleURL = bookmark.articleURL.updateHost(to: newHost) {
                bookmark.articleURL = newArticleURL
            }
        }
        fromZim.tabs.forEach { (tab: Tab) in
            tab.zimFile = toZim
            tab.interactionState = tab.interactionState?.updateHost(to: newHost)
        }
        context.delete(fromZim)
        if context.hasChanges { try? context.save() }
    }

    @MainActor
    private static func latestZimFileHost() async -> String {
        if let newHost = Self.newHost { return newHost }
        // if it wasn't set before, set and return by the last ZimFile in DB:
        guard let zimFile = try? Database.shared.viewContext.fetch(requestLatestZimFile).first else {
            fatalError("we should have at least 1 zim file for a custom app")
        }
        let newHost = zimFile.fileID.uuidString
        // save the new host for later
        Self.newHost = newHost
        return newHost
    }
}

extension URL {
    func updateHost(to newHost: String) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        components.host = newHost
        return components.url
    }
}

extension Data {
    func updateHost(to newHost: String) -> Data {
        let string = String(decoding: self, as: UTF8.self)
        if let replaced = try? string.replacingRegex(
            matching: "kpapp:\\/\\/[A-Z0-9-]{0,36}\\/",
            with: "kpapp://\(newHost)/"
        ) {
            return Data(replaced.utf8)
        } else {
            return self
        }
    }
}
