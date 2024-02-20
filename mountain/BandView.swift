//
//  BandView.swift
//  mountain
//
//  Created by Thore Jahn on 19.02.24.
//

import SwiftUI

struct BandView: View {
    var band: Band
    var body: some View {
            ScrollView {
                Text(band.discriptiopn)
                    .padding()
                HStack {
                    Link(destination: URL(string: band.bandcamp)!, label: {
                        Image("Streaming/bandcamp_logo")
                            .resizable()
                            .scaledToFit()
                    })
                    Link(destination: URL(string: band.appleMusic)!, label: {
                        Image("Streaming/apple_music")
                            .resizable()
                            .scaledToFit()
                    })
                    Link(destination: URL(string: band.spotify)!, label: {
                        Image("Streaming/spotify_logo")
                            .resizable()
                            .scaledToFit()
                    })
                }
                .padding()
            }
            .navigationTitle(band.name)
    }
}

#Preview {
    BandView(band: bands[2])
}
