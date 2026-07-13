// This file is part of Kpapp for iOS.

import Foundation
import CoreData

extension Migrations {
    /// Change the bookmarks articleURLs from "kpapp://..." to "zim://..."
    /// - Parameter context: DataBase context
    /// - Returns: Migration - general struct
    static func schemeToZIM(using context: NSManagedObjectContext) -> Migration {
        Migration(userDefaultsKey: "migrate_scheme_to_zim") {
            // bookmarks:
            let bookmarkPredicate = NSPredicate(format: "articleURL BEGINSWITH[cd] %@", "kpapp://")
            let bookmarkRequest = Bookmark.fetchRequest(predicate: bookmarkPredicate)
            let bookmarks: [Bookmark] = (try? context.fetch(bookmarkRequest)) ?? []
            for bookmark in bookmarks {
                bookmark.articleURL = bookmark.articleURL.updatedToZIMSheme()
            }
            if context.hasChanges {
                try? context.save()
            }
            return true
        }
    }
}
