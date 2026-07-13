// This file is part of Kpapp for iOS.

import Foundation
import CoreData
@testable import Kpapp

final class TestContext: DBObjectContext {
    
    private let objectContext = NSManagedObjectContext(.privateQueue)
    
    var zimFiles: [ZimFile] = []
    
    func fetchZimFiles() throws -> [ZimFile] {
        zimFiles
    }
    
    func bulkInsert(handler: @escaping (ZimFile) -> Bool) throws -> Int {
        var count = 0
        var zimFile = ZimFile(context: objectContext)
        while handler(zimFile) == false {
            zimFiles.append(zimFile)
            zimFile = ZimFile(context: objectContext)
            count += 1
        }
        return count
    }
    
    func bulkDeleteNotDownloadedZims(notIncludedIn: Set<UUID>) throws -> Int {
        let oldCount = zimFiles.count
        zimFiles = zimFiles.filter { zimFile in
            notIncludedIn.contains(zimFile.fileID) || zimFile.fileURLBookmark != nil
        }
        let newCount = zimFiles.count
        return oldCount - newCount
    }
    
}

final class TestDatabase: Databasing {
    
    var context: DBObjectContext = TestContext()
    
    func backgroundTask(_ block: @escaping (any DBObjectContext) -> Void) {
        block(context)
    }
}
