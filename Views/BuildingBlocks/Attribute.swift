// This file is part of Kpapp for iOS.

import SwiftUI

struct Attribute: View {
    let title: String
    let detail: String?

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(detail ?? LocalString.attribute_detail_unknown).foregroundColor(.secondary)
        }
    }
}

struct AttributeBool: View {
    let title: String
    let detail: Bool

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if detail {
                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
            } else {
                Image(systemName: "multiply.circle.fill").foregroundColor(.orange)
            }
        }
    }
}
