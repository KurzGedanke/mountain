//
//  mountainApp.swift
//  mountain
//
//  Created by Thore Jahn on 14.02.24.
//

import SwiftUI

@main
struct mountainApp: App {
    @State private var lineup = LineupStore()
    @State private var favorites = FavoritesStore()
    @State private var reminders = ReminderManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(lineup)
                .environment(favorites)
                .environment(reminders)
                .task {
                    await lineup.refresh()
                    await reminders.sync(favorites: favorites.ids, slots: lineup.slots)
                }
        }
    }
}
