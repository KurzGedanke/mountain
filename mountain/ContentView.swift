//
//  ContentView.swift
//  mountain
//
//  Created by Thore Jahn on 14.02.24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            WelcomeView()
                .tabItem {
                    Label("Home", systemImage: "house") }
            BillingView()
                .tabItem {
                    Label("Bands", systemImage: "music.note.list") }
//            DongMapView()
//                .tabItem {
//                    Label("Karte", systemImage: "map") }
        }
    }
}

#Preview {
    ContentView()
}
