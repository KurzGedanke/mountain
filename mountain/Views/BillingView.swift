//
//  Billing.swift
//  mountain
//
//  Created by Thore Jahn on 19.02.24.
//

import SwiftUI

struct BillingView: View {
    var body: some View {
        NavigationView {
                List {
                    ForEach(bands, id: \.name) {band in
                        NavigationLink(destination: BandView(band: band)) {
                            Text(band.name)
                    }
                }
            }
            .navigationTitle("Bands")
        }
    }
}

#Preview {
    BillingView()
}
