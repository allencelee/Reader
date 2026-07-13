// This file is part of Kpapp for iOS.

import Foundation
import Combine

struct DownloadState: Codable {
    let downloaded: Int64
    let total: Int64
    let resumeData: Data?
    
    var isPaused: Bool {
        resumeData != nil
    }

    static func empty() -> DownloadState {
        .init(downloaded: 0, total: 1, resumeData: nil)
    }

    init(downloaded: Int64, total: Int64, resumeData: Data?) {
        guard total >= downloaded, total > 0 else {
            assertionFailure("invalid download progress values: downloaded \(downloaded) total: \(total)")
            self.downloaded = downloaded
            self.total = downloaded
            self.resumeData = resumeData
            return
        }
        self.downloaded = downloaded
        self.total = total
        self.resumeData = resumeData
    }

    func updatedWith(downloaded: Int64, total: Int64) -> DownloadState {
        DownloadState(downloaded: downloaded, total: total, resumeData: resumeData)
    }

    func updatedWith(resumeData: Data?) -> DownloadState {
        DownloadState(downloaded: downloaded, total: total, resumeData: resumeData)
    }
}
