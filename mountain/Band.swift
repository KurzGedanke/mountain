//
//  Band.swift
//  mountain
//
//  Created by Thore Jahn on 19.02.24.
//

import Foundation
import SwiftUI

struct Band: Identifiable, Decodable {
    let id: Int
    let name: String
    let description: String
    let spotify: String
    let appleMusic: String
    let bandcamp: String
}
