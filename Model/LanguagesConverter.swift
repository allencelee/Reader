// This file is part of Kpapp for iOS.

//
//  Languages.swift
//  Kpapp

import Foundation

enum LanguagesConverter {
    static func convert(codes: Set<String>, validCodes: Set<String>) -> Set<String> {
        let invalidCodes = codes.subtracting(validCodes)
        let validatedCodes = codes.intersection(validCodes)
        // try to convert from iso-2 to iso-3 format:
        let converted = invalidCodes.compactMap(Self.convertToAlpha3(from:))
        let convertedValidatedCodes = Set<String>(converted).intersection(validCodes)
        return validatedCodes.union(convertedValidatedCodes)
    }

    static func convertToAlpha3(from alpha2: String) -> String? {
        Locale.LanguageCode(alpha2).identifier(.alpha3)
    }
}
