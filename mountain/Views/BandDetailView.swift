//
//  BandDetailView.swift
//  mountain
//
//  A single band: artwork, description, set times, streaming links, favorite.
//

import SwiftUI

struct BandDetailView: View {
    @Environment(LineupStore.self) private var lineup
    @Environment(FavoritesStore.self) private var favorites

    let bandId: Int

    var body: some View {
        ScrollView {
            if let band = lineup.band(id: bandId) {
                VStack(alignment: .leading, spacing: 20) {
                    header(band)
                    sets
                    if let description = band.description, !description.isEmpty {
                        Text(description)
                            .font(.body)
                    }
                    links(band)
                }
                .padding()
            } else {
                ContentUnavailableView("Band not found", systemImage: "questionmark")
                    .padding(.top, 80)
            }
        }
        .navigationTitle(lineup.band(id: bandId)?.name ?? "Band")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteButton(bandId: bandId)
                    .font(.title3)
            }
        }
    }

    // MARK: Pieces

    @ViewBuilder
    private func header(_ band: Band) -> some View {
        if let url = band.imageURL {
            // Size is fixed by the clear container; the fill image lives in an
            // overlay so it can't push the layout wider than the screen.
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .overlay {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            placeholderArt
                        default:
                            ZStack { placeholderArt; ProgressView() }
                        }
                    }
                }
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }

        if let genre = band.genre, !genre.isEmpty {
            Text(genre.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }

    private var placeholderArt: some View {
        ZStack {
            Rectangle().fill(.quaternary)
            Image(systemName: "music.mic").font(.largeTitle).foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var sets: some View {
        let slots = lineup.slots(forBand: bandId).sorted { $0.start < $1.start }
        if !slots.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(slots) { slot in
                    Label {
                        Text("\(Fmt.dayTime(slot.start)) · \(slot.stage)")
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .font(.headline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    @ViewBuilder
    private func links(_ band: Band) -> some View {
        if band.hasLinks {
            VStack(alignment: .leading, spacing: 12) {
                Text("Listen & Follow").font(.headline)
                HStack(spacing: 16) {
                    linkButton(band.spotifyURL, "music.note", "Spotify")
                    linkButton(band.appleMusicURL, "applelogo", "Apple Music")
                    linkButton(band.bandcampURL, "waveform", "Bandcamp")
                    linkButton(band.instagramURL, "camera", "Instagram")
                }
            }
        }
    }

    @ViewBuilder
    private func linkButton(_ url: URL?, _ symbol: String, _ label: String) -> some View {
        if let url {
            Link(destination: url) {
                VStack(spacing: 6) {
                    Image(systemName: symbol).font(.title2)
                    Text(label).font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}
