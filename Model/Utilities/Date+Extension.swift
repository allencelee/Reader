// This file is part of Kpapp for iOS.

import Foundation

extension Date {
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        return formatter
    }()

    /// Format the current date the way as it would come from a server's Last-Modified header
    /// - Returns: eg: Thu, 16 May 2024 11:38:20 GMT
    func formatAsGMT() -> String {
        Self.dateFormatter.string(from: self)
    }
}
