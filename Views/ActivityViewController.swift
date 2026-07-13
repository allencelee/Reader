// This file is part of Kpapp for iOS.

import SwiftUI

#if os(iOS)
struct ActivityViewController: UIViewControllerRepresentable {

    @Environment(\.dismiss) var dismissAction
    var activityItems: [Any]

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ActivityViewController>
    ) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.completionWithItemsHandler = { (_, _, _, _) in
            self.dismissAction()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}
#endif
