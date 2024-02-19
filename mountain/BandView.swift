//
//  BandView.swift
//  mountain
//
//  Created by Thore Jahn on 19.02.24.
//

import SwiftUI

struct BandView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Behemoth ist eine ganz tolle band!")
                Text("Donnerstag")
                Text("12:30")
            }
            .navigationTitle("Behemoth")
            .toolbar {
                Button("Zurück", systemImage: "arrow.backward", action: {})
            }
        }
    }
}

#Preview {
    BandView()
}
