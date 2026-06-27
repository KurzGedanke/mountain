//
//  SettingsView.swift
//  mountain
//
//  App settings: appearance (light / dark / system) and a link to the
//  About page. The chosen appearance is persisted and applied app-wide.
//

import SwiftUI

/// User-selectable appearance, persisted via @AppStorage("appearance").
enum AppearanceSetting: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    /// `nil` means "follow the system".
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var label: LocalizedStringKey {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

struct SettingsView: View {
    @AppStorage("appearance") private var appearance: AppearanceSetting = .system
    @AppStorage("remindersEnabled") private var remindersEnabled = true

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Appearance", selection: $appearance) {
                    ForEach(AppearanceSetting.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                Toggle("Reminders", isOn: $remindersEnabled)
            } header: {
                Text("Notifications")
            } footer: {
                Text("Get a reminder 15 minutes before a favorited band plays.")
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
