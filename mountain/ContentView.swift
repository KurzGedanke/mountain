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
            RunningOrder()
                .tabItem {
                    Label("Runnung Order", systemImage: "music.mic") }
            
        }
    }
}

#Preview {
    ContentView()
}
