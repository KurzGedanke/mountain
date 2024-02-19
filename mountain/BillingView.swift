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
                Text("Behemoth")
                Text("Blind Gurdian")
                Text("Deserted Fear")
            }        
            .navigationTitle("Bands")
        }
    }
}

#Preview {
    BillingView()
}
