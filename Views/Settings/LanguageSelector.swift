// This file is part of Kpapp for iOS.

import CoreData
import SwiftUI


struct LanguageSelector: View {
    @Default(.libraryLanguageSortingMode) private var sortingMode
    @State private var showing = [Language]()
    @State private var hiding = [Language]()

    var body: some View {
        List {
            Section {
                if showing.isEmpty {
                    Text(LocalString.language_selector_no_language_title).foregroundColor(.secondary)
                } else {
                    ForEach(showing) { language in
                        Button { hide(language) } label: { LanguageLabel(language: language) }
                    }
                }
            } header: { Text(LocalString.language_selector_showing_header) }
            Section {
                ForEach(hiding) { language in
                    Button { show(language) } label: { LanguageLabel(language: language) }
                }
            } header: { Text(LocalString.language_selector_hiding_header) }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(LocalString.language_selector_navitation_title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Picker(selection: $sortingMode) {
                ForEach(LibraryLanguageSortingMode.allCases) { sortingMode in
                    Text(sortingMode.name).tag(sortingMode)
                }
            } label: {
                Label(LocalString.language_selector_toolbar_sorting, systemImage: "arrow.up.arrow.down")
            }.pickerStyle(.menu)
        }
        .onAppear {
            Task {
                var languages = await Languages.fetch()
                languages.sort(by: Languages.compare(lhs:rhs:))
                showing = languages.filter { Defaults[.libraryLanguageCodes].contains($0.code) }
                hiding = languages.filter { !Defaults[.libraryLanguageCodes].contains($0.code) }
            }
        }
        .onChange(of: sortingMode) { _ in
            showing.sort(by: Languages.compare(lhs:rhs:))
            hiding.sort(by: Languages.compare(lhs:rhs:))
        }
    }

    private func show(_ language: Language) {
        Defaults[.libraryLanguageCodes].insert(language.code)
        withAnimation {
            hiding.removeAll { $0.code == language.code }
            showing.append(language)
            showing.sort(by: Languages.compare(lhs:rhs:))
        }
    }

    private func hide(_ language: Language) {
        guard Defaults[.libraryLanguageCodes].count > 1 else {
            // we should not remove all languages, it will produce empty results
            return
        }
        Defaults[.libraryLanguageCodes].remove(language.code)
        withAnimation {
            showing.removeAll { $0.code == language.code }
            hiding.append(language)
            hiding.sort(by: Languages.compare(lhs:rhs:))
        }
    }
}

private struct LanguageLabel: View {
    let language: Language

    var body: some View {
        HStack {
            Text(language.name).foregroundColor(.primary)
            Spacer()
            Text("\(language.count)").foregroundColor(.secondary)
        }
    }
}

class Languages {
    /// Retrieve a list of languages.
    /// - Returns: languages with count of zim files in each language
    static func fetch() async -> [Language] {
        let count = NSExpressionDescription()
        count.name = "count"
        count.expression = NSExpression(forFunction: "count:", arguments: [NSExpression(forKeyPath: "languageCode")])
        count.expressionResultType = .integer16AttributeType

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ZimFile")
        // exclude the already downloaded files, they might have invalid language set
        // but we are mainly interested in fetched content
        fetchRequest.predicate = ZimFile.Predicate.notDownloaded
        fetchRequest.propertiesToFetch = ["languageCode", count]
        fetchRequest.propertiesToGroupBy = ["languageCode"]
        fetchRequest.resultType = .dictionaryResultType

        let languages: [Language] = await withCheckedContinuation { continuation in
            Database.shared.performBackgroundTask { context in
                guard let results = try? context.fetch(fetchRequest) else {
                    continuation.resume(returning: [])
                    return
                }
                let collector = LanguageCollector()
                for result in results {
                    if let result = result as? NSDictionary,
                       let languageCodes = result["languageCode"] as? String,
                       let count = result["count"] as? Int {
                        collector.addLanguages(codes: languageCodes, count: count)
                    }
                }
                continuation.resume(returning: collector.languages())
            }
        }
        return languages
    }

    /// Compare two languages based on library language sorting order.
    /// Can be removed once support for iOS 14 drops.
    /// - Parameters:
    ///   - lhs: one language to compare
    ///   - rhs: another language to compare
    /// - Returns: if one language should appear before or after another
    static func compare(lhs: Language, rhs: Language) -> Bool {
        switch Defaults[.libraryLanguageSortingMode] {
        case .alphabetically:
            return lhs.name.caseInsensitiveCompare(rhs.name) == .orderedAscending
        case .byCounts:
            return lhs.count > rhs.count
        }
    }
}
