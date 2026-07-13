// This file is part of Kpapp for iOS.

import SwiftUI

struct HotspotDetails: View {
    let address: URL
    let qrCodeImage: CGImage?
    private let vSpace: CGFloat = 18
    
    private enum Const {
        static let imageWidth: CGFloat = 220
    }
    
    var body: some View {
        HotspotCell {
            HStack {
                VStack(alignment: .center, spacing: vSpace) {
                    Text(LocalString.hotspot_server_active_warning)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                    
                    Text(address.absoluteString)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                    HStack {
                        ShareLink(item: address) {
                            Label(LocalString.common_button_share, systemImage: "square.and.arrow.up")
                        }
                        Spacer(minLength: 32)
                        DynamicCopyButton(action: { CopyPaste.copyToPasteBoard(url: address) })
                    }
                    .frame(width: Const.imageWidth)
                }
                Spacer()
            }
        }
        
        HotspotCell {
            HStack {
                Spacer()
                VStack(spacing: vSpace) {
                    Group {
                        if let qrCodeImage {
                            Image(qrCodeImage, scale: 1, label: Text(address.absoluteString))
                                .resizable()
                        } else {
                            ProgressView().progressViewStyle(.circular)
                        }
                    }
                    .frame(width: Const.imageWidth, height: Const.imageWidth)
                    .aspectRatio(1.0, contentMode: .fill)
                    
                    if let qrCodeImage {
                        HStack {
                            let img = Image(qrCodeImage, scale: 1, label: Text(address.absoluteString))
                            ShareLink(
                                item: img,
                                preview: SharePreview(address.absoluteString, image: img)
                            ) {
                                Label(
                                    LocalString.common_button_share,
                                    systemImage: "square.and.arrow.up"
                                )
                            }
                            Spacer(minLength: 32)
                            DynamicCopyButton(action: { CopyPaste.copyToPasteBoard(image: qrCodeImage) })
                        }
                        .frame(width: Const.imageWidth)
                    }
                }
                Spacer()
            }
        }
        
        HotspotCell {
            HotspotExplanation()
        }
    }
}
