//
//  ContentView.swift
//  mountain
//
//  Created by Thore Jahn on 14.02.24.
//

import SwiftUI

enum AppTab: Hashable { case now, lineup, settings }

struct ContentView: View {
    @Environment(LineupStore.self) private var lineup
    @Environment(FavoritesStore.self) private var favorites
    @Environment(ReminderManager.self) private var reminders

    @AppStorage("appearance") private var appearance: AppearanceSetting = .system

    @State private var selection: AppTab = {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-startTab"), i + 1 < args.count else { return .now }
        switch args[i + 1] {
        case "lineup": return .lineup
        case "settings", "about": return .settings
        default: return .now
        }
    }()

    var body: some View {
        TabView(selection: $selection) {
            Tab("Now", systemImage: "play.circle.fill", value: AppTab.now) {
                HomeView()
            }
            Tab("Line-up", systemImage: "list.bullet", value: AppTab.lineup) {
                RunningOrderView()
            }
            Tab("Settings", systemImage: "gearshape", value: AppTab.settings) {
                SettingsView()
            }
        }
        .preferredColorScheme(appearance.colorScheme)
        // Re-schedule reminders whenever favorites change; ask permission the
        // first time the user actually favorites something.
        .task(id: favorites.ids) {
            if !favorites.ids.isEmpty && !reminders.authorized {
                await reminders.requestAuthorization()
            }
            await reminders.sync(favorites: favorites.ids, slots: lineup.slots)
        }
    }
}

#Preview {
    ContentView()
        .environment(LineupStore())
        .environment(FavoritesStore())
        .environment(ReminderManager())
}
