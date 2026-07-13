// This file is part of Kpapp for iOS.

import Foundation

extension Defaults.Keys {
//    // reading
    static let webViewTextSizeAdjustFactor = Key<Double>("webViewZoomScale", default: 1)
    static let webViewPageZoom = Key<Double>("webViewPageZoom", default: 1)
    static let externalLinkLoadingPolicy = Key<ExternalLinkLoadingPolicy>(
        "externalLinkLoadingPolicy", default: Brand.defaultExternalLinkPolicy
    )
    static let searchResultSnippetMode = Key<SearchResultSnippetMode>(
        "searchResultSnippetMode", default: Brand.defaultSearchSnippetMode
    )

    // search
    static let recentSearchTexts = Key<[String]>("recentSearchTexts", default: [])

    // library
    static let libraryLanguageCodes = Key<Set<String>>("libraryLanguageCodes", default: Set())
    static let libraryETag = Key<String>("libraryETag", default: "")
    static let libraryLanguageSortingMode = Key<LibraryLanguageSortingMode>(
        "libraryLanguageSortingMode", default: LibraryLanguageSortingMode.byCounts
    )
    static let libraryAutoRefresh = Key<Bool>("libraryAutoRefresh", default: true)
    static let libraryUsingOldISOLangCodes = Key<Bool>("libraryUsingOldISOLangCodes", default: true)
    static let libraryLastRefresh = Key<Date?>("libraryLastRefresh")

    static let isFirstLaunch = Key<Bool>("isFirstLaunch", default: true)
    static let downloadUsingCellular = Key<Bool>("downloadUsingCellular", default: false)
    static let backupDocumentDirectory = Key<Bool>("backupDocumentDirectory", default: false)

    static let categoriesToLanguages = Key<[Category: Set<String>]>("categoriesToLanguages", default: [:])
    static let hasSeenCategories = Key<Bool>("hasSeenCategories", default: false)
    
    static let hotspotPortNumber = Key<Int>("hotspotPortNumber", default: Hotspot.defaultPort)
}
