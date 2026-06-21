//
//  FavoritesStore.swift
//  mountain
//
//  Favorited bands, keyed by the API's stable band id and persisted in
//  UserDefaults. Kept completely separate from the line-up snapshot so that
//  refreshing the schedule never disturbs the user's favorites.
//

import Foundation
import Observation
import TelemetryDeck

@MainActor
@Observable
final class FavoritesStore {
    private static let key = "favoriteBandIDs"

    private(set) var ids: Set<Int>

    init() {
        let stored = UserDefaults.standard.array(forKey: Self.key) as? [Int] ?? []
        ids = Set(stored)
    }

    func isFavorite(_ bandId: Int) -> Bool { ids.contains(bandId) }

    func toggle(_ bandId: Int) {
        let nowFavorite = !ids.contains(bandId)
        if nowFavorite {
            ids.insert(bandId)
        } else {
            ids.remove(bandId)
        }
        UserDefaults.standard.set(Array(ids), forKey: Self.key)

        TelemetryDeck.signal(
            nowFavorite ? "Band.favorited" : "Band.unfavorited",
            parameters: ["bandID": String(bandId)]
        )
    }
}
