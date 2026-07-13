// This file is part of Kpapp for iOS.

import Foundation

enum HTTPSuccess {
    static func response(
        url: URL,
        metaData: URLContentMetaData,
        requestedRange: ClosedRange<UInt>?
    ) -> HTTPURLResponse? {
        if let requestedRange {
            return Self.http206Response(
                url: url,
                metaData: metaData,
                requestedRange: requestedRange
            )
        } else {
            return Self.http200Response(
                url: url,
                metaData: metaData
            )
        }
    }

    private static func http200Response(
        url: URL,
        metaData: URLContentMetaData
    ) -> HTTPURLResponse? {
        var headers = defaultResponseHeaders(for: metaData)
        headers["Content-Length"] = "\(metaData.size)"
        return HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )
    }

    private static func http206Response(
        url: URL,
        metaData: URLContentMetaData,
        requestedRange: ClosedRange<UInt>
    ) -> HTTPURLResponse? {
        var headers = defaultResponseHeaders(for: metaData)
        headers["Content-Length"] = "\(requestedRange.fullRangeSize)"
        headers["Content-Range"] = metaData.contentRange(for: requestedRange)
        return HTTPURLResponse(
            url: url,
            statusCode: 206,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )
    }

    private static func defaultResponseHeaders(for metaData: URLContentMetaData) -> [String: String] {
        var headers = [
            "Accept-Ranges": "bytes",
            "Content-Type": metaData.httpContentType,
            "Date": Date().formatAsGMT()
        ]
        if let modifiedDate = metaData.lastModified {
            headers["Last-Modified"] = modifiedDate.formatAsGMT()
        }
        if let eTag = metaData.eTag {
            headers["ETag"] = eTag
        }
        return headers
    }
}
