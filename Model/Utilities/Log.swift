// This file is part of Kpapp for iOS.

import os

private let subsystem = "org.kpapp.kpapp"

struct Log {
    static let DownloadService = Logger(subsystem: subsystem, category: "DownloadService")
    static let FaviconDownloadService = Logger(subsystem: subsystem, category: "FaviconDownloadService")
    static let LibraryOperations = Logger(subsystem: subsystem, category: "LibraryOperations")
    static let QRCode = Logger(subsystem: subsystem, category: "QRCode")
    static let OPDS = Logger(subsystem: subsystem, category: "OPDS")
    static let URLSchemeHandler = Logger(subsystem: subsystem, category: "URLSchemeHandler")
    static let Branding = Logger(subsystem: subsystem, category: "Branding")
    static let Payment = Logger(subsystem: subsystem, category: "Payment")
}
