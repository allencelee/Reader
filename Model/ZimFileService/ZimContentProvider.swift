// This file is part of Kpapp for iOS.

import Foundation

/// Async reading data in chunks via LibZim
/// to be used with ``DataStream``
struct ZimContentProvider: DataProvider {
    
    typealias Element = URLContent
    private let url: URL

    init(for url: URL) {
        self.url = url
    }

    func data(from start: UInt, to end: UInt) async -> URLContent? {
        await ZimFileService.shared.getURLContent(url: url, start: start, end: end)
    }
}

/// Async reading data in chunks directly from the file system
/// to be used with ``DataStream``
struct ZimDirectContentProvider: DataProvider {

    typealias Element = URLContent
    private let directAccess: DirectAccessInfo
    private let contentSize: UInt

    init(directAccess: DirectAccessInfo, contentSize: UInt) {
        self.directAccess = directAccess
        self.contentSize = contentSize
    }

    func data(from start: UInt, to end: UInt) async -> URLContent? {
        return await withCheckedContinuation { continuation in
            Task.detached(priority: .utility) {
                let handle = FileHandle(forReadingAtPath: directAccess.path)
                try? handle?.seek(toOffset: UInt64(directAccess.offset + start))
                let dataLength = Int(min(contentSize - start, end - start + 1))
                let data = handle?.readData(ofLength: dataLength)
                try? handle?.close()
                let urlContent: URLContent?
                if let data {
                    urlContent = URLContent(data: data, start: start, end: end)
                } else {
                    urlContent = nil
                }
                continuation.resume(returning: urlContent)
            }
        }
    }
}
