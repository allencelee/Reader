// This file is part of Kpapp for iOS.

import SwiftUI

/// On receiving a  URL, it offers to save the content of it as a file
struct SaveContentHandler: ViewModifier {

    private let saveContentToFile = NotificationCenter.default.publisher(for: .saveContent)
    #if os(iOS)
    @State private var kpappURL: URL?
    @State private var urlAndContent: (URL, URLContent)?
    #endif

    // swiftlint:disable:next function_body_length
    func body(content: Content) -> some View {
        content.onReceive(saveContentToFile) { notification in
            guard let url = notification.userInfo?["url"] as? URL,
                  url.isZIMURL else {
                return
            }
            kpappURL = url
        }
#if os(iOS)
        .alert(isPresented: Binding<Bool>.constant($kpappURL.wrappedValue != nil)) {
            Alert(title: Text(LocalString.common_export_file_alert_title),
                  message: Text(
                    LocalString.common_export_file_alert_description(withArgs: kpappURL?.lastPathComponent ?? "")
                  ),
                  primaryButton: .default(Text(LocalString.common_export_file_alert_button_title)) {
                Task { @MainActor in
                    if let kpappURL,
                       let urlContent = await ZimFileService.shared.getURLContent(url: kpappURL) {
                        urlAndContent = (kpappURL, urlContent)
                    } else {
                        urlAndContent = nil
                    }
                    kpappURL = nil
                }
            },
                  secondaryButton: .cancel {
                kpappURL = nil
            }
            )
        }
        .sheet(
            isPresented: Binding<Bool>.constant($urlAndContent.wrappedValue != nil),
            onDismiss: {
                if let (url, _) = urlAndContent,
                   let tempURL = url.tempFileURL() {
                    try? FileManager.default.removeItem(at: tempURL)
                }
                urlAndContent = nil
            }, content: {
                if let (url, urlContent) = urlAndContent {
                    if let tempURL = url.tempFileURL(),
                       (try? urlContent.data.write(to: tempURL)) != nil {
                        ActivityViewController(activityItems: [tempURL])
                    }
                }
            }
        )
#endif
    }
}

extension URL {
    fileprivate func tempFileURL() -> URL? {
        let directory = FileManager.default.temporaryDirectory
        return directory.appending(path: lastPathComponent)
    }
}
