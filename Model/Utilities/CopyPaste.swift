// This file is part of Kpapp for iOS.

import SwiftUI
import UniformTypeIdentifiers

enum CopyPaste {
    public static func copyToPasteBoard(url: URL) {
        UIPasteboard.general.setValue(url.absoluteString, forPasteboardType: UTType.url.identifier)
    }
    
    public static func copyToPasteBoard(image: CGImage) {
        #if os(iOS)
        UIPasteboard.general.image = UIImage(cgImage: image)
        #else
        NSPasteboard.general.clearContents()
        let size = CGSize(width: image.width, height: image.height)
        let nsImage = NSImage(cgImage: image, size: size)
        let tiffData = nsImage.tiffRepresentation
        NSPasteboard.general.setData(tiffData, forType: .tiff)
        #endif
    }
}
