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

    private(set) var ids: Set<Int>

    init() {
        let stored = UserDefaults.standard.array(forKey: Self.key) as? [Int] ?? []
        ids = Set(stored)
    }

    func isFavorite(_ bandId: Int) -> Bool { ids.contains(bandId) }

    func toggle(_ bandId: Int) {
        if ids.contains(bandId) {
            ids.remove(bandId)
        } else {
            ids.insert(bandId)
        }
        UserDefaults.standard.set(Array(ids), forKey: Self.key)
    }
}
