// This file is part of Kpapp for iOS.

import SwiftUI

struct Favicon: View {
    @State private var imageData: Data?

    private let category: Category
    private let imageURL: URL?

    init(category: Category, imageData: Data? = nil, imageURL: URL? = nil) {
        self.category = category
        self.imageURL = imageURL
        self._imageData = State(wrappedValue: imageData)
    }

    var body: some View {
        image.scaledToFit().cornerRadius(3)
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            guard let imageURL = imageURL, imageData == nil else { return }
            Database.shared.saveImageData(url: imageURL) { data in
                imageData = data
            }
        }
    }

    @ViewBuilder
    var image: some View {
        if let data = imageData, let image = UIImage(data: data) {
            Image(uiImage: image).resizable()
        } else {
            Image(category.icon).resizable()
        }
    }
}

@available(iOS 15.0, *)
struct Favicon_Previews: PreviewProvider {
    static var previews: some View {
        Favicon(
            category: .wikipedia,
            imageData: nil,
            imageURL: URL(
                string: "https://opds.library.kpapp.com/v2/illustration/e82e6816-a2dc-a7f0-2d15-58d24709db93/?size=48"
            )!
        ).frame(width: 200, height: 200).previewLayout(.sizeThatFits)
        Favicon(
            category: .ted,
            imageData: nil,
            imageURL: nil
        ).frame(width: 200, height: 200).previewLayout(.sizeThatFits)
    }
}
