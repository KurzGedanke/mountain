//
//  mountainApp.swift
//  mountain
//
//  Created by Thore Jahn on 14.02.24.
//

import SwiftUI
import TelemetryDeck

@main
struct mountainApp: App {
    @State private var lineup = LineupStore()
    @State private var favorites = FavoritesStore()
    @State private var reminders = ReminderManager()

    @AppStorage("remindersEnabled") private var remindersEnabled = true

    init() {
        let config = TelemetryDeck.Config(appID: "463DFAC5-B137-4E5A-B3DA-2810E0AE27B8")
        config.defaultSignalPrefix = "de.kurzgedanke."
        TelemetryDeck.initialize(config: config)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(lineup)
                .environment(favorites)
                .environment(reminders)
                .task {
                    await lineup.refresh()
                    await reminders.sync(enabled: remindersEnabled,
                                         favorites: favorites.ids, slots: lineup.slots,
                                         autographFavorites: favorites.autographIDs, autographs: lineup.autographs)
                }
        }
    }
}
