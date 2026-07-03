//
//  HomeView.swift
//  mountain
//
//  "Now & Next" board plus the user's favorited bands and their next sets.
//  Wrapped in a TimelineView so the live state advances on its own.
//

import SwiftUI

struct HomeView: View {
    @Environment(LineupStore.self) private var lineup
    @Environment(FavoritesStore.self) private var favorites

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 30)) { context in
                content(now: context.date)
            }
            .navigationTitle("Dong Open Air")
            .toolbar { RefreshToolbar() }
            .refreshable { await lineup.refresh() }
        }
    }

    @ViewBuilder
    private func content(now: Date) -> some View {
        let playing = lineup.nowPlaying(at: now)
        let next = lineup.upNext(at: now)
        let favoriteSlots = upcomingFavoriteSlots(now: now)
        let nextAutograph = upcomingFavoriteAutographs(now: now).first

        List {
            if lineup.isEmpty {
                ContentUnavailableView(
                    "No line-up yet",
                    systemImage: "wifi.slash",
                    description: Text("Connect to the internet once to download the schedule.")
                )
            } else {
                nowSection(playing)
                nextSection(next)
                autographSection(nextAutograph)
                favoritesSection(favoriteSlots, now: now)
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: Sections

    @ViewBuilder
    private func nowSection(_ slots: [TimeSlot]) -> some View {
        Section("Now") {
            if slots.isEmpty {
                Text("Nothing on stage right now.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(slots) { slot in
                    SlotRow(slot: slot, emphasized: true)
                }
            }
        }
    }

    @ViewBuilder
    private func nextSection(_ slots: [TimeSlot]) -> some View {
        if !slots.isEmpty {
            Section("Up next") {
                ForEach(slots) { slot in
                    SlotRow(slot: slot, emphasized: false)
                }
            }
        }
    }

    @ViewBuilder
    private func autographSection(_ session: AutographSession?) -> some View {
        if let session {
            Section("Your next autograph session") {
                AutographRow(session: session)
            }
        }
    }

    @ViewBuilder
    private func favoritesSection(_ slots: [TimeSlot], now: Date) -> some View {
        Section("Your bands") {
            if favorites.ids.isEmpty {
                Text("Tap the star on a band to follow it. You'll get a reminder before they play.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else if slots.isEmpty {
                Text("No upcoming sets for your favorites.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(slots) { slot in
                    SlotRow(slot: slot, emphasized: false, showDay: true)
                }
            }
        }
    }

    private func upcomingFavoriteSlots(now: Date) -> [TimeSlot] {
        lineup.slots
            .filter { favorites.isFavorite($0.bandId) }
            .filter { ($0.end ?? $0.start.addingTimeInterval(3600)) >= now }
            .sorted { $0.start < $1.start }
    }

    private func upcomingFavoriteAutographs(now: Date) -> [AutographSession] {
        lineup.autographs
            .filter { favorites.isFavoriteAutograph($0.id) }
            .filter { ($0.end ?? $0.start.addingTimeInterval(3600)) >= now }
            .sorted { $0.start < $1.start }
    }
}

/// One favorited autograph session: thumbnail, band, time/point, star, link.
private struct AutographRow: View {
    @Environment(LineupStore.self) private var lineup
    let session: AutographSession

    var body: some View {
        NavigationLink {
            BandDetailView(bandId: session.bandId)
        } label: {
            HStack(spacing: 12) {
                if let band = lineup.band(id: session.bandId) {
                    BandThumbnail(band: band)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.band)
                    Text("\(Fmt.dayTime(session.start)) · \(session.signingPoint)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .accessibilityLabel(Text("Favorited"))
            }
        }
    }
}

/// One schedule entry: thumbnail, band, time/stage, star, and a link to detail.
/// The star here is a non-interactive indicator — favoriting happens on the band
/// detail screen so a stray tap on the Now board can't drop a favorite.
private struct SlotRow: View {
    @Environment(LineupStore.self) private var lineup
    @Environment(FavoritesStore.self) private var favorites
    let slot: TimeSlot
    var emphasized: Bool = false
    var showDay: Bool = false

    var body: some View {
        NavigationLink {
            BandDetailView(bandId: slot.bandId)
        } label: {
            HStack(spacing: 12) {
                if let band = lineup.band(id: slot.bandId) {
                    BandThumbnail(band: band)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(slot.band)
                        .font(emphasized ? .headline : .body)
                    Text(timeText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if favorites.isFavorite(slot.bandId) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .accessibilityLabel(Text("Favorited"))
                }
            }
        }
    }

    private var timeText: String {
        let time = showDay ? Fmt.dayTime(slot.start) : Fmt.range(slot.start, slot.end)
        return "\(time) · \(slot.stage)"
    }
}

/// Toolbar refresh button shared by the tabs.
struct RefreshToolbar: ToolbarContent {
    @Environment(LineupStore.self) private var lineup

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task { await lineup.refresh() }
            } label: {
                if lineup.status == .loading {
                    ProgressView()
                } else {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .disabled(lineup.status == .loading)
        }
    }
}
