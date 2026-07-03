//
//  BaphometAPI.swift
//  mountain
//
//  Read-only client for https://bands.baphomet.club.
//
//  Quirks handled here:
//   - The festival and stages are addressed by their slug (e.g.
//     `dong-open-air-2026`, `hauptbuhne`), returned by the list endpoints.
//   - Date fields come back as a verbose PHP DateTime object; we only read the
//     embedded unix `timestamp` and ignore the multi-megabyte timezone tables.
//

import Foundation

struct BaphometAPI: Sendable {
    static let festival = "Dong Open Air 2026"
    static let festivalSlug = "dong-open-air-2026"

    private let base = URL(string: "https://bands.baphomet.club")!

    /// A PHP `DateTime` as serialized by Symfony. We only need the timestamp.
    private struct PHPDate: Decodable {
        let timestamp: Int
        var date: Date { Date(timeIntervalSince1970: TimeInterval(timestamp)) }
    }

    private struct APIStage: Decodable {
        let name: String
        let slug: String
    }

    private struct APITimeSlot: Decodable {
        let band: String
        let bandSlug: String
        let bandId: Int
        let stage: String
        let startTime: PHPDate
        let endTime: PHPDate?
    }

    private struct APIAutograph: Decodable {
        let band: String
        let bandSlug: String
        let bandId: Int
        let signingPoint: String
        let location: String?
        let startTime: PHPDate
        let endTime: PHPDate?
    }

    /// Fetches bands + every stage's schedule + autographs and assembles a fresh snapshot.
    func fetchSnapshot() async throws -> LineupSnapshot {
        async let bandsTask = fetchBands()
        async let autographsTask = fetchAutographs()
        let stages = try await fetchStages()

        var slots: [TimeSlot] = []
        for stage in stages {
            slots.append(contentsOf: try await fetchTimeslots(stageSlug: stage.slug))
        }

        let bands = try await bandsTask
        var autographs = try await autographsTask
        slots.sort { $0.start < $1.start }
        autographs.sort { $0.start < $1.start }
        return LineupSnapshot(
            festival: Self.festival,
            stages: stages.map(\.name),
            bands: bands,
            slots: slots,
            autographs: autographs,
            updatedAt: Date()
        )
    }

    private func fetchBands() async throws -> [Band] {
        let url = base
            .appending(path: "api/festivals")
            .appending(path: Self.festivalSlug)
            .appending(path: "bands")
        return try await get(url, as: [Band].self)
    }

    private func fetchStages() async throws -> [APIStage] {
        let url = base
            .appending(path: "api/festivals")
            .appending(path: Self.festivalSlug)
            .appending(path: "stages")
        return try await get(url, as: [APIStage].self)
    }

    private func fetchTimeslots(stageSlug: String) async throws -> [TimeSlot] {
        let url = base
            .appending(path: "api/festivals")
            .appending(path: Self.festivalSlug)
            .appending(path: "stages")
            .appending(path: stageSlug)
            .appending(path: "timeslots")
        let api = try await get(url, as: [APITimeSlot].self)
        return api.map {
            TimeSlot(
                bandId: $0.bandId,
                band: $0.band,
                bandSlug: $0.bandSlug,
                stage: $0.stage,
                start: $0.startTime.date,
                end: $0.endTime?.date
            )
        }
    }

    private func fetchAutographs() async throws -> [AutographSession] {
        let url = base
            .appending(path: "api/festivals")
            .appending(path: Self.festivalSlug)
            .appending(path: "autographs")
        let api = try await get(url, as: [APIAutograph].self)
        return api.map {
            AutographSession(
                bandId: $0.bandId,
                band: $0.band,
                bandSlug: $0.bandSlug,
                signingPoint: $0.signingPoint,
                location: $0.location,
                start: $0.startTime.date,
                end: $0.endTime?.date
            )
        }
    }

    private func get<T: Decodable>(_ url: URL, as type: T.Type) async throws -> T {
        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
