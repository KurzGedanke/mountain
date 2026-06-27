//
//  ContentView.swift
//  mountain
//
//  Created by Thore Jahn on 14.02.24.
//

import SwiftUI

enum AppTab: Hashable { case now, lineup, settings }

/// Drives the reminder-sync `.task`: re-runs when favorites or the
/// notifications toggle change.
private struct ReminderSyncKey: Hashable {
    let enabled: Bool
    let favorites: Set<Int>
}

struct ContentView: View {
    @Environment(LineupStore.self) private var lineup
    @Environment(FavoritesStore.self) private var favorites
    @Environment(ReminderManager.self) private var reminders

    @AppStorage("appearance") private var appearance: AppearanceSetting = .system
    @AppStorage("remindersEnabled") private var remindersEnabled = true

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
            Tab("Information", systemImage: "info.circle", value: AppTab.settings) {
                InfoView()
            }
        }
        .preferredColorScheme(appearance.colorScheme)
        // Re-schedule reminders whenever favorites or the notifications toggle
        // change; ask permission the first time the user enables a reminder.
        .task(id: ReminderSyncKey(enabled: remindersEnabled, favorites: favorites.ids)) {
            if remindersEnabled && !favorites.ids.isEmpty && !reminders.authorized {
                await reminders.requestAuthorization()
            }
            await reminders.sync(enabled: remindersEnabled, favorites: favorites.ids, slots: lineup.slots)
        }
    }
}

#Preview {
    ContentView()
        .environment(LineupStore())
        .environment(FavoritesStore())
        .environment(ReminderManager())
}
