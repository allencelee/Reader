// This file is part of Kpapp for iOS.

import SwiftUI


enum PortNumberFormatter {
    static let instance: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = false
        return formatter
    }()
}


import PassKit
import Combine

struct Settings: View {

    let scrollToHotspot: Bool
    @Default(.backupDocumentDirectory) private var backupDocumentDirectory
    @Default(.downloadUsingCellular) private var downloadUsingCellular
    @Default(.externalLinkLoadingPolicy) private var externalLinkLoadingPolicy
    @Default(.libraryAutoRefresh) private var libraryAutoRefresh
    @Default(.searchResultSnippetMode) private var searchResultSnippetMode
    @Default(.webViewPageZoom) private var webViewPageZoom
    @EnvironmentObject private var colorSchemeStore: UserColorSchemeStore
    @EnvironmentObject private var library: LibraryViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    enum Route {
        case languageSelector, about
    }
    
    func openDonation() {
        NotificationCenter.openDonations()
    }

    var body: some View {
        Group {
            ScrollViewReader { proxy in
                List {
                    if FeatureFlags.hasLibrary {
                        readingSettings
                        downloadSettings
                        catalogSettings
                        miscellaneous
                        hotspot.id("hotspot")
                        backupSettings
                    } else {
                        readingSettings
                        miscellaneous
                        hotspot.id("hotspot")
                    }
                }
                .modifier(ToolbarRoleBrowser())
                .navigationTitle(LocalString.settings_navigation_title)
                .task {
                    if scrollToHotspot {
                        proxy.scrollTo("hotspot", anchor: .top)
                    }
                }
            }
        }
    }

    var readingSettings: some View {
        let isSnippet = Binding {
            switch searchResultSnippetMode {
            case .matches: return true
            case .disabled: return false
            }
        } set: { isOn in
            searchResultSnippetMode = isOn ? .matches : .disabled
        }
        return Section(LocalString.reading_settings_tab_reading) {
            // Theme
            Picker(LocalString.theme_settings_title, selection: $colorSchemeStore.userColorScheme) {
                ForEach(UserColorScheme.allCases) { colorScheme in
                    Text(colorScheme.name).tag(colorScheme)
                }
            }
            
            Stepper(value: $webViewPageZoom, in: 0.5...2, step: 0.05) {
                Text(LocalString.reading_settings_zoom_title +
                     ": \(Formatter.percent.string(from: NSNumber(value: webViewPageZoom)) ?? "")")
            }
            if FeatureFlags.showExternalLinkOptionInSettings {
                Picker(LocalString.reading_settings_external_link_title, selection: $externalLinkLoadingPolicy) {
                    ForEach(ExternalLinkLoadingPolicy.allCases) { loadingPolicy in
                        Text(loadingPolicy.name).tag(loadingPolicy)
                    }
                }
            }
            if FeatureFlags.showSearchSnippetInSettings {
                Toggle(LocalString.reading_settings_search_snippet_title, isOn: isSnippet)
            }
        }
    }

    var downloadSettings: some View {
        Section {
            Toggle(LocalString.library_settings_toggle_cellular, isOn: $downloadUsingCellular)
        } header: {
            Text(LocalString.library_settings_downloads_title)
        } footer: {
            Text(LocalString.library_settings_new_download_task_description)
        }
    }

    var catalogSettings: some View {
        Section {
            NavigationLink {
                LanguageSelector()
            } label: {
                SelectedLanaguageLabel()
            }.disabled(library.state != .complete)
            HStack {
                if library.state == .error {
                    Text(LocalString.library_refresh_error_retrieve_description).foregroundColor(.red)
                } else {
                    Text(LocalString.catalog_settings_last_refresh_text)
                    Spacer()
                    LibraryLastRefreshTime().foregroundColor(.secondary)
                }
            }
            if library.state == .inProgress {
                HStack {
                    Text(LocalString.catalog_settings_refreshing_text).foregroundColor(.secondary)
                    Spacer()
                    ProgressView().progressViewStyle(.circular)
                }
            } else {
                Button(LocalString.catalog_settings_refresh_now_button) {
                    library.start(isUserInitiated: true)
                }
            }
            Toggle(LocalString.catalog_settings_auto_refresh_toggle, isOn: $libraryAutoRefresh)
        } header: {
            Text(LocalString.catalog_settings_header_text)
        } footer: {
            Text(LocalString.catalog_settings_footer_text)
        }
    }

    var backupSettings: some View {
        Section {
            Toggle(LocalString.backup_settings_toggle_title, isOn: $backupDocumentDirectory)
        } header: {
            Text(LocalString.backup_settings_header_text)
        } footer: {
            Text(LocalString.backup_settings_footer_text)
        }.onChange(of: backupDocumentDirectory) { LibraryOperations.applyFileBackupSetting(isEnabled: $0) }
    }

    var miscellaneous: some View {
        Section(LocalString.settings_miscellaneous_title) {
            if Payment.paymentButtonType() != nil, horizontalSizeClass != .regular {
                SupportKpappButton {
                    openDonation()
                }
            }
            Button(LocalString.settings_miscellaneous_button_feedback) {
                UIApplication.shared.open(URL(string: "mailto:feedback@kpapp.com")!)
            }
            Button(LocalString.settings_miscellaneous_button_rate_app) {
                let url = URL(appStoreReviewForName: Brand.appName.lowercased(),
                              appStoreID: Brand.appStoreId)
                UIApplication.shared.open(url)
            }
            NavigationLink(LocalString.settings_miscellaneous_navigation_about) { About() }
        }
    }
    
    var hotspot: some View {
        Section {
            PortInput(focusOnPortInput: scrollToHotspot)
        } header: {
            Text(LocalString.enum_navigation_item_hotspot)
        } footer: {
            Text(Hotspot.validPortRangeMessage())
        }
    }
}

private struct SelectedLanaguageLabel: View {
    @Default(.libraryLanguageCodes) private var languageCodes

    var body: some View {
        HStack {
            Text(LocalString.settings_selected_language_title)
            Spacer()
            if languageCodes.count == 1,
               let languageCode = languageCodes.first,
                let languageName = Locale.current.localizedString(forLanguageCode: languageCode) {
                Text(languageName).foregroundColor(.secondary)
            } else if languageCodes.count > 1 {
                Text("\(languageCodes.count)").foregroundColor(.secondary)
            }
        }
    }
}
