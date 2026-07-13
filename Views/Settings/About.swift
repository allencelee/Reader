// This file is part of Kpapp for iOS.

import SwiftUI

import CoreModel

struct About: View {
    @State private var dependencies = [Dependency]()
    @State private var externalLinkURL: URL?

    var body: some View {
        List {
            Section {
                about
                ourWebsite
            }
            Section(LocalString.settings_about_release) {
                release
                appVersion
                buildNumber
                source
                license
            }
            Section(LocalString.settings_about_dependencies) {
                ForEach(dependencies) { dependency in
                    HStack {
                        Text(dependency.name)
                        Spacer()
                        if let license = dependency.license {
                            Text("\(license) (\(dependency.version))").foregroundColor(.secondary)
                        } else {
                            Text(dependency.version).foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(LocalString.settings_about_title)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: externalLinkURL) { url in
            guard let url = url else { return }
            UIApplication.shared.open(url)
        }
        .task { await getDependencies() }
    }

    private var about: some View {
        Text(Brand.aboutText)
    }

    private var release: some View {
        Text(LocalString.settings_about_license_description)
    }

    private var appVersion: some View {
        Attribute(title: LocalString.settings_about_appverion_title,
                  detail: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)
    }

    private var buildNumber: some View {
        Attribute(title: LocalString.settings_about_build_title,
                  detail: Bundle.main.infoDictionary?["CFBundleVersion"] as? String)
    }

    private var ourWebsite: some View {
        Button(LocalString.settings_about_our_website_button) {
            externalLinkURL = URL(string: "\(Brand.aboutWebsite)")
        }
    }

    private var source: some View {
        Button(LocalString.settings_about_source_title) {
            externalLinkURL = URL(string: "")
        }
    }

    private var license: some View {
        Button(LocalString.settings_about_button_license) {
            externalLinkURL = URL(string: "https://www.gnu.org/licenses/gpl-3.0.en.html")
        }
    }

    private func getDependencies() async {
        dependencies = kiwix.getVersions().map { datum in
            Dependency(name: String(datum.first), version: String(datum.second))
        }
    }
}

private struct Dependency: Identifiable {
    var id: String { name }

    let name: String
    let version: String

    var license: String? {
        switch name {
        case "libkiwix":
            "GPLv3"
        case "libzim":
            "GPLv2"
        case "libxapian":
            "GPLv2"
        case "libicu":
            "ICU"
        default:
            nil
        }
    }
}

#Preview {
    NavigationStack { About() }
}
