//
//  LineupStore.swift
//  mountain
//
//  Owns the line-up snapshot. Offline-first: on launch it serves the cached
//  snapshot (or the bundled seed if there is no cache yet), then tries to
//  refresh from the API. A failed refresh leaves the cached data in place.
//

import Foundation
import Observation

@MainActor
@Observable
final class LineupStore {
    enum Status: Equatable { case idle, loading, updated, offline }

    private(set) var snapshot: LineupSnapshot
    private(set) var status: Status = .idle

    private let api = BaphometAPI()

    init() {
        snapshot = Self.loadCachedOrSeed()
    }

    // MARK: Derived data

    var bands: [Band] { snapshot.bands.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending } }
    var slots: [TimeSlot] { snapshot.slots }
    var autographs: [AutographSession] { snapshot.autographs }
    var updatedAt: Date? { snapshot.updatedAt }
    var isEmpty: Bool { snapshot.slots.isEmpty && snapshot.bands.isEmpty }

    func band(id: Int) -> Band? { snapshot.bands.first { $0.id == id } }
    func slots(forBand id: Int) -> [TimeSlot] { snapshot.slots.filter { $0.bandId == id } }
    func autographs(forBand id: Int) -> [AutographSession] {
        snapshot.autographs.filter { $0.bandId == id }.sorted { $0.start < $1.start }
    }

    /// Bands currently on stage at `date`. Falls back to a 1h window when a
    /// slot has no explicit end time.
    func nowPlaying(at date: Date = .now) -> [TimeSlot] {
        snapshot.slots.filter { slot in
            let end = slot.end ?? slot.start.addingTimeInterval(3600)
            return slot.start <= date && date < end
        }
    }

    /// The next slot still to start on each stage, soonest first.
    func upNext(at date: Date = .now) -> [TimeSlot] {
        var perStage: [String: TimeSlot] = [:]
        for slot in snapshot.slots where slot.start > date {
            if perStage[slot.stage] == nil { perStage[slot.stage] = slot }
        }
        return perStage.values.sorted { $0.start < $1.start }
    }

    // MARK: Refresh

    func refresh() async {
        status = .loading
        do {
            let fresh = try await api.fetchSnapshot()
            snapshot = fresh
            Self.persist(fresh)
            status = .updated
        } catch {
            status = .offline
        }
    }

    // MARK: Persistence

    private static func cacheURL() -> URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return dir.appending(path: "lineup_cache.json")
    }

    private static func loadCachedOrSeed() -> LineupSnapshot {
        let decoder = JSONDecoder()
        if let data = try? Data(contentsOf: cacheURL()),
           let cached = try? decoder.decode(LineupSnapshot.self, from: data) {
            return cached
        }
        if let url = Bundle.main.url(forResource: "lineup_seed", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let seed = try? decoder.decode(LineupSnapshot.self, from: data) {
            return seed
        }
        return .empty(festival: BaphometAPI.festival)
    }

    private static func persist(_ snapshot: LineupSnapshot) {
        do {
            let data = try JSONEncoder().encode(snapshot)
            let url = cacheURL()
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: url, options: .atomic)
        } catch {
            // Cache write is best-effort; the in-memory snapshot still works.
        }
    }
}
