// This file is part of Kpapp for iOS.

import Foundation

struct FileExportData {
    let data: Data
    let fileName: String
    let fileExtension: String?

    init(data: Data, fileName: String, fileExtension: String? = "pdf") {
        self.data = data
        self.fileName = fileName
        self.fileExtension = fileExtension
    }
}

enum FileExporter {

    static func tempFileFrom(exportData: FileExportData) -> URL? {
        let extensionToAppend: String
        if let fileExtension = exportData.fileExtension {
            extensionToAppend = ".\(fileExtension)"
        } else {
            extensionToAppend = ""
        }
        guard let tempFileName = exportData.fileName.split(separator: ".").first?.appending(extensionToAppend) else {
            return nil
        }
        let tempFileURL = URL(temporaryFileWithName: tempFileName)
        guard (try? exportData.data.write(to: tempFileURL)) != nil else {
            return nil
        }
        return tempFileURL
    }
}
