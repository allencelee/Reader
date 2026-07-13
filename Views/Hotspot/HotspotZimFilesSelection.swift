// This file is part of Kpapp for iOS.

import SwiftUI

/// A grid of zim files that are opened, or was open but is now missing.
/// A specific version of ZimFilesOpened, supporting multi selection for HotSpot
struct HotspotZimFilesSelection: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ZimFile.size, ascending: false)],
        predicate: ZimFile.openedPredicate,
        animation: .easeInOut
    ) private var zimFiles: FetchedResults<ZimFile>
    @StateObject private var selection: MultiSelectedZimFilesViewModel
    @ObservedObject private var hotspot = HotspotObservable.shared
    @State private var presentedSheet: PresentedSheet?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var hotspotError: (String, String)?
    
    private enum PresentedSheet: Identifiable {
        case shareHotspot(url: URL)
        
        var id: String {
            switch self {
            case .shareHotspot: return "shareHotspot"
            }
        }
    }
    
    init(
        selectionProvider: @MainActor () -> MultiSelectedZimFilesViewModel = { @MainActor in HotspotState.selection }
    ) {
        let selectionInstance = selectionProvider()
        _selection = StateObject(wrappedValue: selectionInstance)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if zimFiles.isEmpty {
                Message(text: LocalString.zim_file_opened_overlay_no_opened_message)
            } else {
                if case .started(let address, let qrCodeImage) = hotspot.state {
                    ScrollView {
                        HStack(alignment: .center) {
                            VStack(alignment: .center, spacing: 12) {
                                Spacer()
                                LazyVGrid(
                                    columns: [GridItem(.flexible(minimum: 250, maximum: 303), spacing: 12)],
                                    alignment: .center,
                                    spacing: 12
                                ) {
                                    HotspotDetails(address: address, qrCodeImage: qrCodeImage)
                                }
                                Spacer()
                            }
                        }
                    }
                } else {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 250, maximum: 500), spacing: 12)],
                        alignment: .center,
                        spacing: 12
                    ) {
                        ForEach(zimFiles) { zimFile in
                            MultiZimFilesSelectionContext(
                                content: {
                                    ZimFileCell(
                                        zimFile,
                                        prominent: .name,
                                        isSelected: selection.isSelected(zimFile),
                                        backgroundColoring: CellBackground.hotspotSelectionColorFor
                                    )
                                },
                                zimFile: zimFile,
                                selection: selection
                            )
                        }
                    }
                    .modifier(GridCommon(edges: .all))
                }
            }
        }
        .modifier(ToolbarRoleBrowser())
        .navigationTitle(MenuItem.hotspot.name)
        .task {
            // make sure that our selection only contains still existing ZIM files
            selection.intersection(with: Set(zimFiles))
            if !FeatureFlags.hasLibrary, let customZIM = zimFiles.first {
                selection.singleSelect(zimFile: customZIM)
            }
        }
        .onReceive(hotspot.$state, perform: { state in
            switch state {
            case .started:
                hotspotError = nil
            case .stopped:
                hotspotError = nil
            case let .error(title, description):
                hotspotError = (title, description)
            }
        })
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                AsyncButton {
                    await hotspot.toggleWith(
                        zimFileIds: Set(selection.selectedZimFiles.map { $0.fileID })
                    )
                } label: {
                    Text(hotspot.buttonTitle)
                        .bold()
                }
                .disabled(selection.selectedZimFiles.isEmpty && !hotspot.state.isStarted)
                .modifier(BadgeModifier(count: selection.selectedZimFiles.count))
            }
        }
        .alert(isPresented: Binding<Bool>.constant($hotspotError.wrappedValue != nil)) {
            
            let settingButton = Alert.Button.default(Text(LocalString.settings_navigation_title), action: {
                dismissAlert()
                NotificationCenter.navigateToHotspotSettings()
            })
            let okButton = Alert.Button.default(Text(LocalString.common_button_ok), action: { dismissAlert() })

            let primary = settingButton
            let secondary = okButton
            
            return Alert(title: Text(hotspotError?.0 ?? ""),
                         message: Text(hotspotError?.1 ?? ""),
                         primaryButton: primary,
                         secondaryButton: secondary
            )
        }
    }
    
    private func dismissAlert() {
        hotspotError = nil
        // at the end resetError is also setting hotspotError to nil
        // but it's just too slow for UI
        hotspot.resetError()
    }
}
