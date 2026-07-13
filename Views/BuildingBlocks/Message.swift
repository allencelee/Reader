// This file is part of Kpapp for iOS.

import SwiftUI

struct Message: View {
    private let text: String
    private let foregroundColor: Color

    init(text: String, color: Color = .secondary) {
        self.text = text
        foregroundColor = color
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text(text).font(.title2).foregroundColor(foregroundColor)
                Spacer()
            }
            Spacer()
        }
    }
}

struct Message_Previews: PreviewProvider {
    static var previews: some View {
        Message(text: "There is nothing to see")
            .frame(width: 250, height: 200)
    }
}
