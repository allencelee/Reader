// This file is part of Kpapp for iOS.

import Foundation

public enum LibraryRefreshError: LocalizedError {
    case retrieve(description: String?)
    case parse
    case process

    public var errorDescription: String? {
        switch self {
        case .retrieve(let description):
            let prefix = LocalString.library_refresh_error_retrieve_description
            return [prefix, description].compactMap({ $0 }).joined(separator: " ")
        case .parse:
            return LocalString.library_refresh_error_parse_description
        case .process:
            return LocalString.library_refresh_error_process_description
        }
    }
}
