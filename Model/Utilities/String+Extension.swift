// This file is part of Kpapp for iOS.

import Foundation

extension String {

    func removingPrefix(_ value: String) -> String {
        guard hasPrefix(value) else { return self }
        return String(dropFirst(value.count))
    }
    
    func removingSuffix(_ value: String) -> String {
        guard hasSuffix(value) else { return self }
        return String(dropLast(value.count))
    }

    func replacingRegex(
        matching pattern: String,
        findingOptions: NSRegularExpression.Options = .caseInsensitive,
        replacingOptions: NSRegularExpression.MatchingOptions = [],
        with template: String
    ) throws -> String {
        let regex = try NSRegularExpression(pattern: pattern, options: findingOptions)
        let range = NSRange(startIndex..., in: self)
        return regex.stringByReplacingMatches(in: self, options: replacingOptions, range: range, withTemplate: template)
    }
}
