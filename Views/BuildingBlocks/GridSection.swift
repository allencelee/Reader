// This file is part of Kpapp for iOS.

import SwiftUI

struct GridSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        Section {
            content
        } header: {
            Text(title).font(.title3).fontWeight(.semibold)
        }
    }
}


struct GridSection_Previews: PreviewProvider {
    static var previews: some View {
        GridSection(title: "Header Text") {
            Text("Content")
        }
    }
}
