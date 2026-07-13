// This file is part of Kpapp for iOS.

import CoreData
import XCTest
import SwiftUI
@testable import Kpapp

// swiftlint:disable force_try
final class CategoryFetchingTests: XCTestCase {

    override func setUpWithError() throws {
        try resetDB()
    }

    @MainActor
    func testFilteredOutByLanguage() throws {
        // insert a zimFile
        let context = Database.shared.viewContext
        let zimFile = ZimFile(context: context)
        let metadata = ZimFileMetaData.mock(languageCodes: "eng",
                                            category: Category.other.rawValue)
        LibraryOperations.configureZimFile(zimFile, metadata: metadata)
        try? context.save()
        let request = NSFetchRequest<ZimFile>(entityName: ZimFile.entity().name!)
        request.predicate = ZimFilesCategory.buildPredicate(
            category: .other,
            searchText: "",
            languageCodes: Set(["x"])
        )
        let results = try! context.fetch(request)
        XCTAssertTrue(results.isEmpty)
    }

    @MainActor
    func testCanBeFoundByLanguage() throws {
        // insert a zimFile
        let context = Database.shared.viewContext
        let zimFile = ZimFile(context: context)
        let metadata = ZimFileMetaData.mock(languageCodes: "eng",
                                            category: Category.other.rawValue)
        LibraryOperations.configureZimFile(zimFile, metadata: metadata)
        try? context.save()
        let request = NSFetchRequest<ZimFile>(entityName: ZimFile.entity().name!)
        request.predicate = ZimFilesCategory.buildPredicate(
            category: .other,
            searchText: "",
            languageCodes: Set(["eng"])
        )
        let results = try! context.fetch(request)
        XCTAssertEqual(results.count, 1)
    }

    @MainActor
    func testCanBeFoundByMultipleUserLanguages() throws {
        // insert a zimFile
        let context = Database.shared.viewContext
        let zimFile = ZimFile(context: context)
        let metadata = ZimFileMetaData.mock(languageCodes: "fra",
                                            category: Category.other.rawValue)
        LibraryOperations.configureZimFile(zimFile, metadata: metadata)
        try? context.save()
        let request = NSFetchRequest<ZimFile>(entityName: ZimFile.entity().name!)
        request.predicate = ZimFilesCategory.buildPredicate(
            category: .other,
            searchText: "",
            languageCodes: Set(["eng", "deu", "fra", "ita", "por"])
        )
        let results = try! context.fetch(request)
        XCTAssertEqual(results.count, 1)
    }

    @MainActor
    func testCanBeFoundHavingMultiLanguagesWithASingleUserLanguage() throws {
        // insert a zimFile
        let context = Database.shared.viewContext
        let zimFile = ZimFile(context: context)
        let metadata = ZimFileMetaData.mock(languageCodes: "eng,fra,deu,nld,spa,ita,por,pol,ara,vie,kor",
                                            category: Category.other.rawValue)
        LibraryOperations.configureZimFile(zimFile, metadata: metadata)
        try? context.save()
        let request = NSFetchRequest<ZimFile>(entityName: ZimFile.entity().name!)
        request.predicate = ZimFilesCategory.buildPredicate(
            category: .other,
            searchText: "",
            languageCodes: Set(["spa"])
        )
        let results = try! context.fetch(request)
        XCTAssertEqual(results.count, 1)
    }

    @MainActor
    func testCanBeFoundHavingMultiLanguageMatches() throws {
        // insert a zimFile
        let context = Database.shared.viewContext
        let zimFile = ZimFile(context: context)
        let metadata = ZimFileMetaData.mock(languageCodes: "eng,fra,deu,nld,spa,ita,por,pol,ara,vie,kor",
                                            category: Category.other.rawValue)
        LibraryOperations.configureZimFile(zimFile, metadata: metadata)
        try? context.save()
        let request = NSFetchRequest<ZimFile>(entityName: ZimFile.entity().name!)
        request.predicate = ZimFilesCategory.buildPredicate(
            category: .other,
            searchText: "",
            languageCodes: Set(["nld", "por", "fra"])
        )
        let results = try! context.fetch(request)
        XCTAssertEqual(results.count, 1)
    }

    @MainActor
    func testFilteredOutByMultiToMultiLanguageMissMatch() throws {
        // insert a zimFile
        let context = Database.shared.viewContext
        let zimFile = ZimFile(context: context)
        let metadata = ZimFileMetaData.mock(languageCodes: "eng,fra,deu,nld,spa,ita",
                                            category: Category.other.rawValue)
        LibraryOperations.configureZimFile(zimFile, metadata: metadata)
        try? context.save()
        let request = NSFetchRequest<ZimFile>(entityName: ZimFile.entity().name!)
        request.predicate = ZimFilesCategory.buildPredicate(
            category: .other,
            searchText: "",
            languageCodes: Set(["por", "pol", "ara", "vie", "kor"])
        )
        let results = try! context.fetch(request)
        XCTAssertTrue(results.isEmpty)
    }

    private func resetDB() throws {
        _ = try Database.shared.viewContext.execute(
            NSBatchDeleteRequest(
                fetchRequest: NSFetchRequest(entityName: ZimFile.entity().name!)
            )
        )
    }

}

private extension ZimFileMetaData {
    static func mock(fileID: UUID = UUID(),
                     groupIdentifier: String = "test_group_id",
                     title: String = "test ZIM title",
                     fileDescription: String = "test description for test ZIM file",
                     languageCodes: String,
                     category: String = "other",
                     creationDate: Date = .init(timeIntervalSince1970: 0),
                     size: UInt = 1_234,
                     articleCount: UInt = 99,
                     mediaCount: UInt = 33,
                     creator: String = "unit_test_creator",
                     publisher: String = "unit_test_publisher",
                     hasDetails: Bool = false,
                     hasPictures: Bool = false,
                     hasVideos: Bool = false,
                     requiresServiceWorkers: Bool = false,
                     downloadURL: URL? = nil,
                     faviconURL: URL? = nil,
                     faviconData: Data? = nil,
                     flavor: String? = nil) -> ZimFileMetaData {
        ZimFileMetaData(
            fileID: fileID,
            groupIdentifier: groupIdentifier,
            title: title,
            fileDescription: fileDescription,
            languageCodes: languageCodes,
            category: category,
            creationDate: creationDate,
            size: NSNumber(value: size),
            articleCount: NSNumber(value: articleCount),
            mediaCount: NSNumber(value: mediaCount),
            creator: creator,
            publisher: publisher,
            downloadURL: downloadURL,
            faviconURL: faviconURL,
            faviconData: faviconData,
            flavor: flavor,
            hasDetails: hasDetails,
            hasPictures: hasPictures,
            hasVideos: hasVideos,
            requiresServiceWorkers: requiresServiceWorkers
        )
    }
}
// swiftlint:enable force_try
