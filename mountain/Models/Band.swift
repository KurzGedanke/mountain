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
    var localizedDescription: LocalizedText?

    /// Band description in the user's language, falling back to the other when
    /// the preferred one is missing. German is the API default.
    var description: String? { localizedDescription?.resolved() }

    var imageURL: URL? { Self.assetURL(image) }
    var logoURL: URL? { Self.assetURL(logo) }
    var spotifyURL: URL? { Self.url(spotify) }
    var appleMusicURL: URL? { Self.url(appleMusic) }
    var bandcampURL: URL? { Self.url(bandcamp) }
    var instagramURL: URL? { Self.url(instagram) }

    var hasLinks: Bool {
        spotifyURL != nil || appleMusicURL != nil || bandcampURL != nil || instagramURL != nil
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, slug, genre, logo, image
        case instagram, spotify, appleMusic, bandcamp
        case localizedDescription = "description"
    }

    /// A plain URL, treating empty strings as `nil`. Used for social/streaming
    /// links, whose real URLs may legitimately end in `/`.
    private static func url(_ value: String?) -> URL? {
        guard let value, !value.isEmpty else { return nil }
        return URL(string: value)
    }

    /// An image/logo URL. For missing assets the API returns the bare directory
    /// path (e.g. `.../logos/`), so a trailing slash means "no file" → `nil`.
    private static func assetURL(_ value: String?) -> URL? {
        guard let value, !value.hasSuffix("/") else { return nil }
        return Self.url(value)
    }
}

/// A string the API localizes into German (default) and English. Both keys are
/// always present but either value may be `null`.
struct LocalizedText: Codable, Hashable, Sendable {
    var de: String?
    var en: String?

    init(de: String? = nil, en: String? = nil) {
        self.de = de
        self.en = en
    }

    /// Decode the new `{ "de": …, "en": … }` object, or a bare string from the
    /// old API/seed shape, which is treated as German (the API default).
    init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer(),
           let string = try? single.decode(String.self) {
            de = string
            return
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        de = try container.decodeIfPresent(String.self, forKey: .de)
        en = try container.decodeIfPresent(String.self, forKey: .en)
    }

    /// Resolve to the preferred language, falling back to the other when the
    /// preferred value is missing or empty. Defaults to the device language.
    func resolved(preferEnglish: Bool = Self.deviceWantsEnglish) -> String? {
        let primary = preferEnglish ? en : de
        let secondary = preferEnglish ? de : en
        return primary?.nonEmpty ?? secondary?.nonEmpty
    }

    private static var deviceWantsEnglish: Bool {
        Locale.preferredLanguages.first?.hasPrefix("en") ?? false
    }
}

private extension String {
    var nonEmpty: String? { isEmpty ? nil : self }
}
