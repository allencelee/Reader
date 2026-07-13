// This file is part of Kpapp for iOS.

import SwiftUI

#if os(iOS)
/// On receiving FileExportData, it gives the ability to share it
struct FileExportHandler: ViewModifier {

    private let exportFileData = NotificationCenter.default.publisher(for: .exportFileData)
    @State private var temporaryURL: URL?

    func body(content: Content) -> some View {
        content.onReceive(exportFileData) { notification in

            guard let userInfo = notification.userInfo,
                  let exportData = userInfo["data"] as? FileExportData,
                  let tempURL = FileExporter.tempFileFrom(exportData: exportData) else {
                temporaryURL = nil
                return
            }
            temporaryURL = tempURL
        }
        .sheet(
            isPresented: Binding<Bool>.constant($temporaryURL.wrappedValue != nil),
            onDismiss: {
                if let temporaryURL {
                    try? FileManager.default.removeItem(at: temporaryURL)
                }
                temporaryURL = nil
            }, content: {
                ActivityViewController(activityItems: [temporaryURL].compactMap { $0 })
            }
        )
    }
}
#endif
