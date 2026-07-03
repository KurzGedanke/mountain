//
//  InfoView.swift
//  mountain
//
//  General information hub: official festival links, the legal disclaimer,
//  and entry points into Settings and the About page (both submenus).
//

import SwiftUI

struct InfoView: View {
    private static let disclaimer: LocalizedStringKey = """
    This app is an unofficial fan project and is in no way affiliated with DONG OPEN AIR or Dong Kultur e.V. It was not commissioned, authorized, reviewed, or otherwise endorsed by the association.

    It is a purely private project, created out of enthusiasm for the festival. The app pursues no commercial purpose and has no intention of making a profit.

    All names, brands, and logos mentioned are the property of their respective owners. They are used here for informational purposes only. For official information about the festival, please visit the official channels of DONG OPEN AIR or Dong Kultur e.V.

    All information in this app is provided without guarantee.
    """

    var body: some View {
        NavigationStack {
            Form {
                Section("Official channels") {
                    Link(destination: URL(string: "https://www.dongopenair.de/news/")!) {
                        Label("News", systemImage: "newspaper")
                    }
                    Link(destination: URL(string: "https://www.dongopenair.de/infos/")!) {
                        Label("FAQ", systemImage: "questionmark.circle")
                    }
                    Link(destination: URL(string: "https://www.dongopenair.de/anfahrt/")!) {
                        Label("Directions", systemImage: "map")
                    }
                }

                Section {
                    Link(destination: URL(string: "https://github.com/KurzGedanke/mountain-android")!) {
                        Label("Source on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                    Link(destination: URL(string: "https://github.com/KurzGedanke/mountain-android/releases")!) {
                        Label("Download (Releases)", systemImage: "arrow.down.circle")
                    }
                } header: {
                    Text("Android app")
                } footer: {
                    Text("Get the Android version from GitHub.")
                }

                Section {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About", systemImage: "person.crop.circle")
                    }
                }

                Section {
                    Text(Self.disclaimer)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Disclaimer")
                }
            }
            .navigationTitle("Information")
        }
    }
}

#Preview {
    InfoView()
}
