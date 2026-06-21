//
//  AboutView.swift
//  mountain
//
//  About the maker — Thore. Bio, Magic: The Gathering, open-source repos,
//  socials, and a friendly "buy me a beer" / contact note.
//

import SwiftUI

struct AboutView: View {
    private static let mastodonTint = Color(red: 0.38, green: 0.39, blue: 1.0)
    private static let blueskyTint = Color(red: 0.0, green: 0.53, blue: 1.0)

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                header
                bio

                section("Open Source") {
                    Text("Both apps and the API that serves the data are open source.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    LinkRow(
                        url: URL(string: "https://github.com/KurzGedanke/mountain")!,
                        symbol: "chevron.left.forwardslash.chevron.right",
                        tint: .purple,
                        title: "Mountain",
                        subtitle: "github.com/KurzGedanke/mountain"
                    )
                    LinkRow(
                        url: URL(string: "https://github.com/KurzGedanke/band-api")!,
                        symbol: "server.rack",
                        tint: .teal,
                        title: "Band API",
                        subtitle: "github.com/KurzGedanke/band-api"
                    )
                }

                section("Find me online") {
                    LinkRow(
                        url: URL(string: "https://chaos.social/@kurzgedanke")!,
                        symbol: "bubble.left.and.bubble.right.fill",
                        tint: Self.mastodonTint,
                        title: "Mastodon",
                        subtitle: "@kurzgedanke@chaos.social"
                    )
                    LinkRow(
                        url: URL(string: "https://bsky.app/profile/kurzgedanke.de")!,
                        symbol: "cloud.fill",
                        tint: Self.blueskyTint,
                        title: "Bluesky",
                        subtitle: "@kurzgedanke.de"
                    )
                }

                LinkRow(
                    url: URL(string: "mailto:app@kurzgedanke.me")!,
                    symbol: "envelope.fill",
                    tint: .orange,
                    title: "Questions or bug reports?",
                    subtitle: "app@kurzgedanke.me"
                )

                footer
            }
            .padding()
        }
        .navigationTitle("About")
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 12) {
            Image("thore")
                .resizable()
                .scaledToFill()
                .frame(width: 128, height: 128)
                .clipShape(.circle)
                .overlay(Circle().strokeBorder(.quaternary, lineWidth: 1))
                .shadow(radius: 8, y: 4)

            Text("Thore")
                .font(.largeTitle.bold())
            Text("Podcaster & software developer from the Ruhr area")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var bio: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hey, I'm Thore! A podcaster and software developer from the Ruhr area. I've loved Dong Open Air for many years, and this app is basically my little love letter to the festival.")
            Text("I'm also a huge Magic: The Gathering fan. If we bump into each other at Dong, let's play a round. And if you enjoy the app, I'd be happy if you grabbed me a beer.")
        }
        .font(.body)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Footer

    private var footer: some View {
        Text(verbatim: "Mountain \(appVersion)")
            .font(.footnote)
            .foregroundStyle(.tertiary)
            .padding(.top, 4)
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return "v\(v)"
    }

    // MARK: Building blocks

    @ViewBuilder
    private func section(_ title: LocalizedStringKey, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            content()
        }
    }
}

/// A tappable row that opens a URL: colored icon badge, title, subtitle.
private struct LinkRow: View {
    let url: URL
    let symbol: String
    let tint: Color
    let title: LocalizedStringKey
    let subtitle: String

    var body: some View {
        Link(destination: url) {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(tint.gradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(.primary)
                    Text(verbatim: subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
