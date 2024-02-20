//
//  TimerView.swift
//  mountain
//
//  Created by Thore Jahn on 20.02.24.
//

import SwiftUI

struct TimerView: View {
    @State var timeRemaining = 10000
    @State private var currentDate = Date.now
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text("\(timeRemaining)")
                    .onReceive(timer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        }
                    }
    }
}

#Preview {
    TimerView()
}
