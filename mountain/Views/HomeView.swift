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
}

/// One schedule entry: thumbnail, band, time/stage, star, and a link to detail.
private struct SlotRow: View {
    @Environment(LineupStore.self) private var lineup
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
                FavoriteButton(bandId: slot.bandId)
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
