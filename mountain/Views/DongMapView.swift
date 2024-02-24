//
//  DongMapView.swift
//  mountain
//
//  Created by asgard on 24.02.24.
//

import SwiftUI
import MapKit

struct DongMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 51.46920,
            longitude: 6.56773),
        span: MKCoordinateSpan(
            latitudeDelta: 0.005,
            longitudeDelta: 0.005)
        )
    var body: some View {
        Map(coordinateRegion: $region)
        .mapStyle(.imagery)
    }
}

#Preview {
    DongMapView()
}
