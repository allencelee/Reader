// This file is part of Kpapp for iOS.

import Foundation

protocol CategoriesProtocol {
    func has(category: Category, inLanguages langCodes: Set<String>) -> Bool
    func save(_ dictionary: [Category: Set<String>])
    func allCategories() -> [Category]
}

struct CategoriesToLanguages: CategoriesProtocol {
    
    private let defaults: Defaulting
    private let dictionary: [Category: Set<String>]
    
    init(withDefaults defaults: Defaulting = UDefaults()) {
        self.defaults = defaults
        self.dictionary = defaults[.categoriesToLanguages]
    }

    func has(category: Category, inLanguages langCodes: Set<String>) -> Bool {
        guard !langCodes.isEmpty, !dictionary.isEmpty else {
            return true // no languages or category filters provided, do not filter
        }
        guard let languages = dictionary[category] else {
            return false
        }
        return !languages.isDisjoint(with: langCodes)
    }

    func save(_ dictionary: [Category: Set<String>]) {
        defaults[.categoriesToLanguages] = dictionary
    }

    func allCategories() -> [Category] {
        let contentLanguages = defaults[.libraryLanguageCodes]
        return Category.allCases.filter { (category: Category) in
            has(category: category, inLanguages: contentLanguages)
        }
    }
}
