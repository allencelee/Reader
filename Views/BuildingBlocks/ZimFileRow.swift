// This file is part of Kpapp for iOS.

import CoreData
import SwiftUI

struct ZimFileRow: View {
    @ObservedObject var zimFile: ZimFile

    init(_ zimFile: ZimFile) {
        self.zimFile = zimFile
    }

    var body: some View {
        HStack {
            Favicon(
                category: Category(rawValue: zimFile.category) ?? .other,
                imageData: zimFile.faviconData,
                imageURL: zimFile.faviconURL
            ).frame(height: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text(zimFile.name).lineLimit(1)
                Text([
                    Formatter.dateShort.string(from: zimFile.created),
                    Formatter.size.string(fromByteCount: zimFile.size),
                    {
                        "\(zimFile.articleCount.formatted(.number.notation(.compactName))) " +
                        LocalString.zim_file_cell_article_count_suffix
                    }()
                ].joined(separator: ", ")).font(.caption)
            }
            Spacer()
            if zimFile.isMissing { ZimFileMissingIndicator() }
        }
    }
}

struct ZimFileRow_Previews: PreviewProvider {
    static let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    static let zimFile: ZimFile = {
        let zimFile = ZimFile(context: context)
        zimFile.articleCount = 100
        zimFile.category = "wikipedia"
        zimFile.created = Date()
        zimFile.fileID = UUID()
        zimFile.flavor = "mini"
        zimFile.languageCode = "en"
        zimFile.mediaCount = 100
        zimFile.name = "Wikipedia Zim File Name"
        zimFile.persistentID = ""
        zimFile.size = 1000000000

        return zimFile
    }()

    static var previews: some View {
        Group {
            ZimFileRow(ZimFileRow_Previews.zimFile)
                .preferredColorScheme(.light)
                .padding()
                .previewLayout(.sizeThatFits)
            ZimFileRow(ZimFileRow_Previews.zimFile)
                .preferredColorScheme(.dark)
                .padding()
                .previewLayout(.sizeThatFits)
            ZimFileRow(ZimFileRow_Previews.zimFile)
                .preferredColorScheme(.light)
                .padding()
                .previewLayout(.sizeThatFits)
            ZimFileRow(ZimFileRow_Previews.zimFile)
                .preferredColorScheme(.dark)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
