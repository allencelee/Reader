// This file is part of Kpapp for iOS.

import Foundation

/// Helper to collect all language codes with counts,
/// some of them are coma separated entries in the DB, such as "eng,spa,por"
final class LanguageCollector {

    private var items: [String: Int] = [:]

    func addLanguages(codes: String, count: Int) {
        Set(codes.split(separator: ",")).forEach { code in
            addLanguage(code: String(code), count: count)
        }
    }

    func languages() -> [Language] {
        items.compactMap { (code: String, count: Int) -> Language? in
            Language(code: code, count: count)
        }.sorted()
    }

    private func addLanguage(code: String, count: Int) {
        if let previousCount = items[code] {
            items[code] = previousCount + count
        } else {
            items[code] = count
        }
    }

}
