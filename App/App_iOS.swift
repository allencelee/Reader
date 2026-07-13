// This file is part of KpApp for iOS.
//

#if os(iOS)
import SwiftUI
import Combine
import UserNotifications
import os
import CrashReporter

@main
struct KpApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var library = LibraryViewModel()
    @StateObject private var selection = SelectedZimFileViewModel()
    @StateObject private var navigation = NavigationViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var colorSchemeStore = UserColorSchemeStore()
    @State var crashReporter: PLCrashReporter!
    private let fileMonitor: DirectoryMonitor
    
    init() {
        fileMonitor = DirectoryMonitor(url: URL.documentDirectory) { LibraryOperations.scanDirectory($0) }
        UNUserNotificationCenter.current().delegate = appDelegate
        // MARK: - migrations
        if !ProcessInfo.processInfo.arguments.contains("testing") {
            _ = MigrationService().migrateAll()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .ignoresSafeArea()
                .environment(\.managedObjectContext, Database.shared.viewContext)
                .environmentObject(library)
                .environmentObject(selection)
                .environmentObject(navigation)
                .environmentObject(colorSchemeStore)
                .modifier(AlertHandler())
                .modifier(OpenFileHandler())
                .modifier(FileExportHandler())
                .modifier(SaveContentHandler())
                .onChange(of: scenePhase) { newValue in
                    switch newValue {
                    case .inactive:
                        try? Database.shared.viewContext.save()
                    case .active:
                        if FeatureFlags.hasLibrary {
                            Task {
                                await LibraryOperations.reValidate()
                                await navigation.deleteTabsWithMissingZimFiles()
                                await library.start(isUserInitiated: false)
                                await Hotspot.shared.appDidBecomeActive()
                            }
                        } else {
                            Task {
                                await Hotspot.shared.appDidBecomeActive()
                            }
                        }
                    case .background:
                        break
                    @unknown default:
                        break
                    }
                }
                .onOpenURL { url in
                    if url.isFileURL {
                        let deepLinkId = UUID()
                        DeepLinkService.shared.startFor(uuid: deepLinkId)
                        NotificationCenter.openFiles([url], context: .file(deepLinkId: deepLinkId))
                    } else if url.isZIMURL {
                        NotificationCenter.openURL(url)
                    }
                }
                .task {
                    switch AppType.current {
                    case .kpapp:
                        fileMonitor.start()
                        await LibraryOperations.reValidate()
                        if !DeepLinkService.shared.isRunning() {
                            navigation.navigateToMostRecentTab()
                        }
                        LibraryOperations.scanDirectory(URL.documentDirectory)
                        LibraryOperations.applyFileBackupSetting()
                        DownloadService.shared.restartHeartbeatIfNeeded()
                    case let .custom(zimFileURL):
                        await LibraryOperations.open(url: zimFileURL)
                        ZimMigration.forCustomApps()
                        navigation.navigateToMostRecentTab()
                    }
                }
                .onAppear {
                    colorSchemeStore.update()
                    let crashReporterConfig = PLCrashReporterConfig.defaultConfiguration()
                    crashReporter = PLCrashReporter(configuration: crashReporterConfig)
                    crashReporter.enable()
                }
                .modifier(DonationViewModifier())
        }
        .commands {
            CommandGroup(replacing: .undoRedo) {
                NavigationCommands(goBack: {
                    NotificationCenter.default.post(name: .goBack, object: nil)
                }, goForward: {
                    NotificationCenter.default.post(name: .goForward, object: nil)
                })
            }
            CommandGroup(replacing: .textFormatting) {
                PageZoomCommands()
            }
        }
    }

    private class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
        
        /// Storing background download completion handler sent to application delegate
        func application(_ application: UIApplication,
                         handleEventsForBackgroundURLSession identifier: String,
                         completionHandler: @escaping () -> Void) {
            DownloadService.shared.backgroundCompletionHandler = completionHandler
        }

        /// Handling file download complete notification
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {
            Task { @MainActor in
                if let zimFileID = UUID(uuidString: response.notification.request.identifier),
                   let mainPageURL = await ZimFileService.shared.getMainPageURL(zimFileID: zimFileID) {
                    NotificationCenter.openURL(mainPageURL, inNewTab: true)
                }
                completionHandler()
            }
        }

        /// Purge some cached browser view models when receiving memory warning
        func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
            BrowserViewModel.purgeCache()
        }
    }
}

private struct RootView: UIViewControllerRepresentable {
    @EnvironmentObject private var navigation: NavigationViewModel
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ZimFile.size, ascending: false)],
        predicate: ZimFile.openedPredicate,
        animation: .easeInOut
    ) private var zimFiles: FetchedResults<ZimFile>

    func makeUIViewController(context: Context) -> SplitViewController {
        SplitViewController(
            navigationViewModel: navigation,
            hasZimFiles: !zimFiles.isEmpty
        )
    }

    func updateUIViewController(_ controller: SplitViewController, context: Context) {
    }
}
#endif
