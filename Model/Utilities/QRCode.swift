// This file is part of Kpapp for iOS.

import SwiftUI
import CoreImage
import os

struct QRCode {

    static func image(from text: String) async -> CGImage? {
        let data = Data(text.utf8)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            Log.QRCode.error("QRCode cannot create CIFilter")
            return nil
        }
        filter.setValue(data, forKey: "inputMessage")
        
        let context = CIContext()
        let transform = CGAffineTransform(scaleX: 20, y: 20)
        guard let outputImage = filter.outputImage?.transformed(by: transform),
              let image = context.createCGImage(outputImage, from: outputImage.extent.insetBy(dx: 20, dy: 20)) else {
            Log.QRCode.error("QRCode cannot create image")
            return nil
        }
        return image
    }

}
