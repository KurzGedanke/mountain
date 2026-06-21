//
//  Band.swift
//  mountain
//
//  A band in the festival line-up. Matches the `/bands` endpoint payload.
//

import Foundation

struct Band: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let name: String
    let slug: String
    var genre: String?
    var logo: String?
    var image: String?
    var instagram: String?
    var spotify: String?
    var appleMusic: String?
    var bandcamp: String?
    var description: String?

    var imageURL: URL? { Self.url(image) }
    var logoURL: URL? { Self.url(logo) }
    var spotifyURL: URL? { Self.url(spotify) }
    var appleMusicURL: URL? { Self.url(appleMusic) }
    var bandcampURL: URL? { Self.url(bandcamp) }
    var instagramURL: URL? { Self.url(instagram) }

    var hasLinks: Bool {
        spotifyURL != nil || appleMusicURL != nil || bandcampURL != nil || instagramURL != nil
    }

    /// The API returns a trailing-slash URL (e.g. `.../logos/`) when the value is
    /// actually missing, so treat empty / slash-terminated strings as `nil`.
    private static func url(_ value: String?) -> URL? {
        guard let value, !value.isEmpty, !value.hasSuffix("/") else { return nil }
        return URL(string: value)
    }
}
