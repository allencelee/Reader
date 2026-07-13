// This file is part of Kpapp for iOS.

import Foundation

enum URLSchemeType {
    case zim
    case kpapp
    case geo
    case unsupported

    init(scheme: String?) {
        if scheme?.caseInsensitiveCompare("zim") == .orderedSame {
            self = .zim
            return
        }
        if scheme?.caseInsensitiveCompare("kpapp") == .orderedSame {
            self = .kpapp
            return
        }
        if scheme?.caseInsensitiveCompare("geo") == .orderedSame {
            self = .geo
            return
        }
        self = .unsupported
    }
}

extension URL {
    init?(zimFileID: String, contentPath: String) {
        let baseURLString = "zim://" + zimFileID
        guard let encoded = contentPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {return nil}
        self.init(string: encoded, relativeTo: URL(string: baseURLString))
    }

    var schemeType: URLSchemeType {
        URLSchemeType(scheme: scheme)
    }

    var isUnsupported: Bool { schemeType == .unsupported }
    var isZIMURL: Bool { schemeType == .zim }
    var isKpappURL: Bool { schemeType == .kpapp }
    var isGeoURL: Bool { schemeType == .geo }
    var zimFileID: UUID? {
        guard isZIMURL || isKpappURL else { return nil }
        return UUID(uuidString: host ?? "")
    }

    /// Returns the path, that should be used to resolve articles in ZIM files.
    /// It makes sure that trailing slash is preserved,
    /// and leading slash is removed.
    var contentPath: String {
        path(percentEncoded: false).removingPrefix("/")
    }

    // swiftlint:disable:next force_try
    static let documentDirectory = try! FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: false
    )

    init(appStoreReviewForName appName: String, appStoreID: String) {
        self.init(string: "itms-apps://itunes.apple.com/us/app/\(appName)/\(appStoreID)?action=write-review")!
    }

    init(temporaryFileWithName fileName: String) {
        let directory = FileManager.default.temporaryDirectory
        self = directory.appending(path: fileName)
    }

    func toTemporaryFileURL() -> URL? {
        URL(temporaryFileWithName: lastPathComponent)
    }

    /// If it's an old ``kpapp://`` url comming from a pre-migration tab
    /// - Returns: the ``zim://`` url or the original one if it cannot be changed
    func updatedToZIMSheme() -> URL {
        guard isKpappURL, var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        components.scheme = "zim"
        return components.url ?? self
    }
    
    /// Remove the defined components one by one if found
    /// - Parameter pathComponents: eg: /package/details/more can be defined as: ["package", "details", "more"]
    /// - Returns: the modified url
    func trim(pathComponents: [String]) -> URL {
        var result = self
        for component in pathComponents.reversed() where component == result.lastPathComponent {
            result = result.deletingLastPathComponent()
        }
        return result
    }
    
    /// Removes everything after ? or &
    /// - Returns: the modified URL, or the same if it fails to find the components
    func withoutQueryParams() -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        components.queryItems = nil
        return components.url ?? self
    }
}
