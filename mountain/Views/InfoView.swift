//
//  InfoView.swift
//  mountain
//
//  Created by asgard on 25.02.24.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        NavigationView {
            List {
                Text("News")
                Text("About")
                Text("Achknockelments")
            }
        }
    }
}

#Preview {
    InfoView()
}
