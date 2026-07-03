//
//  Formatting.swift
//  mountain
//
//  Shared date formatting + small reusable schedule views.
//

import SwiftUI

enum Fmt {
    /// 20:00
    static func time(_ date: Date) -> String {
        date.formatted(.dateTime.hour().minute())
    }

    /// 20:00 – 21:30  (or just the start if there is no end)
    static func range(_ start: Date, _ end: Date?) -> String {
        guard let end else { return time(start) }
        return "\(time(start)) – \(time(end))"
    }

    /// Saturday, 18 July
    static func day(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }

    /// Sat 22:00
    static func dayTime(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.abbreviated).hour().minute())
    }
}

/// A square band thumbnail backed by the network image, cached by URLCache so
/// it keeps working offline once seen. Falls back to a music glyph.
struct BandThumbnail: View {
    let band: Band
    var size: CGFloat = 48

    var body: some View {
        AsyncImage(url: band.imageURL) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            default:
                ZStack {
                    Rectangle().fill(.quaternary)
                    Image(systemName: "music.mic")
                        .font(.system(size: size * 0.4))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.18, style: .continuous))
    }
}

/// A tappable star that toggles a band's favorite state.
struct FavoriteButton: View {
    @Environment(FavoritesStore.self) private var favorites
    let bandId: Int

    var body: some View {
        Button {
            favorites.toggle(bandId)
        } label: {
            Image(systemName: favorites.isFavorite(bandId) ? "star.fill" : "star")
                .foregroundStyle(favorites.isFavorite(bandId) ? .yellow : .secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(favorites.isFavorite(bandId) ? Text("Remove favorite") : Text("Add favorite"))
    }
}

/// A tappable star that favorites a single autograph session, scheduling a
/// reminder 15 minutes before it starts.
struct AutographFavoriteButton: View {
    @Environment(FavoritesStore.self) private var favorites
    let sessionID: String

    var body: some View {
        Button {
            favorites.toggleAutograph(sessionID)
        } label: {
            Image(systemName: favorites.isFavoriteAutograph(sessionID) ? "star.fill" : "star")
                .foregroundStyle(favorites.isFavoriteAutograph(sessionID) ? .yellow : .secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(favorites.isFavoriteAutograph(sessionID) ? Text("Remove reminder") : Text("Remind me"))
    }
}
