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

@MainActor
@Observable
final class FavoritesStore {
    private static let key = "favoriteBandIDs"
    private static let autographKey = "favoriteAutographIDs"

    private(set) var ids: Set<Int>
    /// Favorited autograph sessions, keyed by `AutographSession.id`. Kept separate
    /// from band favorites: a band can have several sessions, favorited apart.
    private(set) var autographIDs: Set<String>

    init() {
        let stored = UserDefaults.standard.array(forKey: Self.key) as? [Int] ?? []
        ids = Set(stored)
        let storedAutographs = UserDefaults.standard.array(forKey: Self.autographKey) as? [String] ?? []
        autographIDs = Set(storedAutographs)
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

        if nowFavorite { Analytics.bandFavorited(bandId) }
    }

    func isFavoriteAutograph(_ id: String) -> Bool { autographIDs.contains(id) }

    func toggleAutograph(_ id: String) {
        let nowFavorite = !autographIDs.contains(id)
        if nowFavorite {
            autographIDs.insert(id)
        } else {
            autographIDs.remove(id)
        }
        UserDefaults.standard.set(Array(autographIDs), forKey: Self.autographKey)

        if nowFavorite { Analytics.autographFavorited(id) }
    }
}
