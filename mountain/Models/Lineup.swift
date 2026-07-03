//
//  Lineup.swift
//  mountain
//
//  Schedule models. A `TimeSlot` is one band playing one stage at one time.
//  A `LineupSnapshot` is the whole offline-cacheable picture of the festival.
//

import Foundation

struct TimeSlot: Identifiable, Codable, Hashable, Sendable {
    let bandId: Int
    let band: String
    let bandSlug: String
    let stage: String
    let start: Date
    let end: Date?

    /// Stable across reloads: a band plays a given stage start-time at most once.
    var id: String { "\(bandId)-\(Int(start.timeIntervalSince1970))" }

    init(bandId: Int, band: String, bandSlug: String, stage: String, start: Date, end: Date?) {
        self.bandId = bandId
        self.band = band
        self.bandSlug = bandSlug
        self.stage = stage
        self.start = start
        self.end = end
    }

    // Persisted as unix epoch seconds so the cache file stays tiny and portable.
    enum CodingKeys: String, CodingKey { case bandId, band, bandSlug, stage, start, end }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        bandId = try c.decode(Int.self, forKey: .bandId)
        band = try c.decode(String.self, forKey: .band)
        bandSlug = try c.decode(String.self, forKey: .bandSlug)
        stage = try c.decode(String.self, forKey: .stage)
        start = Date(timeIntervalSince1970: try c.decode(TimeInterval.self, forKey: .start))
        if let e = try c.decodeIfPresent(TimeInterval.self, forKey: .end) {
            end = Date(timeIntervalSince1970: e)
        } else {
            end = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(bandId, forKey: .bandId)
        try c.encode(band, forKey: .band)
        try c.encode(bandSlug, forKey: .bandSlug)
        try c.encode(stage, forKey: .stage)
        try c.encode(start.timeIntervalSince1970, forKey: .start)
        try c.encodeIfPresent(end?.timeIntervalSince1970, forKey: .end)
    }
}

/// One band signing autographs at one signing point at one time. Mirrors
/// `TimeSlot`; persisted with epoch-second dates so the cache stays tiny.
struct AutographSession: Identifiable, Codable, Hashable, Sendable {
    let bandId: Int
    let band: String
    let bandSlug: String
    let signingPoint: String
    let location: String?
    let start: Date
    let end: Date?

    /// Stable across reloads: a band signs a given point start-time at most once.
    var id: String { "\(bandId)-\(Int(start.timeIntervalSince1970))" }

    init(bandId: Int, band: String, bandSlug: String, signingPoint: String, location: String?, start: Date, end: Date?) {
        self.bandId = bandId
        self.band = band
        self.bandSlug = bandSlug
        self.signingPoint = signingPoint
        self.location = location
        self.start = start
        self.end = end
    }

    // Persisted as unix epoch seconds so the cache file stays tiny and portable.
    enum CodingKeys: String, CodingKey { case bandId, band, bandSlug, signingPoint, location, start, end }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        bandId = try c.decode(Int.self, forKey: .bandId)
        band = try c.decode(String.self, forKey: .band)
        bandSlug = try c.decode(String.self, forKey: .bandSlug)
        signingPoint = try c.decode(String.self, forKey: .signingPoint)
        location = try c.decodeIfPresent(String.self, forKey: .location)
        start = Date(timeIntervalSince1970: try c.decode(TimeInterval.self, forKey: .start))
        if let e = try c.decodeIfPresent(TimeInterval.self, forKey: .end) {
            end = Date(timeIntervalSince1970: e)
        } else {
            end = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(bandId, forKey: .bandId)
        try c.encode(band, forKey: .band)
        try c.encode(bandSlug, forKey: .bandSlug)
        try c.encode(signingPoint, forKey: .signingPoint)
        try c.encodeIfPresent(location, forKey: .location)
        try c.encode(start.timeIntervalSince1970, forKey: .start)
        try c.encodeIfPresent(end?.timeIntervalSince1970, forKey: .end)
    }
}

struct LineupSnapshot: Codable, Sendable {
    let festival: String
    var stages: [String]
    var bands: [Band]
    var slots: [TimeSlot]
    // Defaulted so snapshots cached before autographs existed still decode.
    var autographs: [AutographSession] = []
    var updatedAt: Date?

    static func empty(festival: String) -> LineupSnapshot {
        LineupSnapshot(festival: festival, stages: [], bands: [], slots: [], autographs: [], updatedAt: nil)
    }
}
