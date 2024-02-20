//
//  TimerView.swift
//  mountain
//
//  Created by Thore Jahn on 20.02.24.
//

import SwiftUI
import Foundation

let fmt = ISO8601DateFormatter()

let date1 = Date.now
let date2 = fmt.date(from: "2024-07-11T12:00:00+0100")!

let diffs = Calendar.current.dateComponents([.second], from: date1, to: date2).second

struct TimerView: View {
    @State var timeRemaining = diffs!
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
