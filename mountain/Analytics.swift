//
//  Analytics.swift
//  mountain
//
//  Deliberately sparse TelemetryDeck wrapper. We record only positive-intent
//  events — a band seen once per session, a favorite added — so signal volume
//  stays low and every signal means something. Repeat views and un-favorites
//  are intentionally not sent.
//

import Foundation
import TelemetryDeck

@MainActor
enum Analytics {
    /// Bands already counted this launch. Opening the same band again (e.g.
    /// navigating back and forth) sends at most one `Band.viewed` per session.
    private static var viewedBands: Set<Int> = []

    static func bandViewed(_ bandId: Int) {
        guard viewedBands.insert(bandId).inserted else { return }
        TelemetryDeck.signal("Band.viewed", parameters: ["bandID": String(bandId)])
    }

    static func bandFavorited(_ bandId: Int) {
        TelemetryDeck.signal("Band.favorited", parameters: ["bandID": String(bandId)])
    }

    static func autographFavorited(_ id: String) {
        TelemetryDeck.signal("Autograph.favorited", parameters: ["autographID": id])
    }
}
