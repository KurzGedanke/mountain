//
//  RunningOrderView.swift
//  mountain
//
//  The full schedule, grouped by day. Each row links to the band and can be
//  favorited inline. Filterable to just your favorites.
//

import SwiftUI

struct RunningOrderView: View {
    @Environment(LineupStore.self) private var lineup
    @Environment(FavoritesStore.self) private var favorites

    @State private var favoritesOnly = false
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                if lineup.isEmpty {
                    ContentUnavailableView(
                        "No line-up yet",
                        systemImage: "wifi.slash",
                        description: Text("Connect to the internet once to download the schedule.")
                    )
                } else {
                    scheduleList
                }
            }
            .navigationTitle("Line-up")
            .toolbar {
                RefreshToolbar()
                ToolbarItem(placement: .topBarLeading) {
                    Toggle(isOn: $favoritesOnly) {
                        Label("Favorites only", systemImage: favoritesOnly ? "star.fill" : "star")
                    }
                    .toggleStyle(.button)
                }
            }
            .refreshable { await lineup.refresh() }
            .searchable(text: $searchText, prompt: "Search bands")
        }
    }

    private var scheduleList: some View {
        List {
            ForEach(days, id: \.self) { day in
                Section(Fmt.day(day)) {
                    ForEach(slots(on: day)) { slot in
                        ScheduleRow(slot: slot)
                    }
                }
            }

            if let updated = lineup.updatedAt, !visibleSlots.isEmpty {
                Text("Updated \(updated.formatted(.relative(presentation: .named)))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.insetGrouped)
        .animation(.default, value: favoritesOnly)
        .overlay {
            if visibleSlots.isEmpty { emptyState }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if !searchText.isEmpty {
            ContentUnavailableView.search(text: searchText)
        } else if favoritesOnly {
            ContentUnavailableView(
                "No favorites",
                systemImage: "star",
                description: Text("Star a band to see it here.")
            )
        }
    }

    // MARK: Grouping

    private var visibleSlots: [TimeSlot] {
        var result = lineup.slots
        if favoritesOnly {
            result = result.filter { favorites.isFavorite($0.bandId) }
        }
        let query = searchText.trimmingCharacters(in: .whitespaces)
        if !query.isEmpty {
            result = result.filter { $0.band.localizedCaseInsensitiveContains(query) }
        }
        return result
    }

    private var days: [Date] {
        let cal = Calendar.current
        let starts = Set(visibleSlots.map { cal.startOfDay(for: $0.start) })
        return starts.sorted()
    }

    private func slots(on day: Date) -> [TimeSlot] {
        let cal = Calendar.current
        return visibleSlots
            .filter { cal.isDate($0.start, inSameDayAs: day) }
            .sorted { $0.start < $1.start }
    }
}

private struct ScheduleRow: View {
    @Environment(LineupStore.self) private var lineup
    let slot: TimeSlot

    var body: some View {
        NavigationLink {
            BandDetailView(bandId: slot.bandId)
        } label: {
            HStack(spacing: 12) {
                Text(Fmt.time(slot.start))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 48, alignment: .leading)

                if let band = lineup.band(id: slot.bandId) {
                    BandThumbnail(band: band, size: 40)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(slot.band)
                    Text(slot.stage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                FavoriteButton(bandId: slot.bandId)
            }
        }
    }
}
