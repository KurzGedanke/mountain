//
//  Band.swift
//  mountain
//
//  Created by Thore Jahn on 19.02.24.
//

import Foundation
import SwiftUI

struct Band {
    let name: String
    let discriptiopn: String
    let spotify: String
    let appleMusic: String
    let bandcamp: String
}

let behemoth = Band (
    name: "Behemoth",
    discriptiopn: "Behemoth ist eine polnische Extreme-Metal-Band. Sie war anfangs dem Black Metal zuzuordnen, im Laufe ihrer Geschichte wurden jedoch stufenweise Elemente des Death Metal in ihren Stil integriert. Mittlerweile gehören sie zu den bekannten Vertretern beider Genres. Der Bandname stammt von dem Ungeheuer der jüdischen sowie christlichen Mythologie.",
    spotify: "https://spotify.com",
    appleMusic: "https://www.apple.com/de/apple-music/",
    bandcamp: "https://bandcamp.com"
)

let blindGurdian = Band (
    name: "Blind Guardian",
    discriptiopn: "Blind Guardian is a German power metal band formed in 1984 in Krefeld, West Germany.[1] They are often credited as one of the seminal and most influential bands in the power metal and speed metal subgenres.[2][3] Nine musicians have been a part of the band's line-up in its history, which currently consists of singer Hansi Kürsch, guitarists André Olbrich and Marcus Siepen and, since 2005, drummer Frederik Ehmke.",
    spotify: "https://spotify.com",
    appleMusic: "https://www.apple.com/de/apple-music/",
    bandcamp: "https://bandcamp.com"
)

let nephylim = Band (
    name: "Nephylim",
    discriptiopn: "In the winter of 2015 longtime friends Kevin van Geffen and Rens van de Ven started a new project mainly focused on Scandinavian Melodic Death metal: Nephylim. After they’ve joined forces with drummer Martijn Paauwe (ex-Mirdyn) and vocalist Lisa van Dijk (ex-Solemnus) the first full setting of the band was set. Together they’ve composed multiple songs of which 5 have ended on the first release of the band: EP “Torn” (released on 15-12-2015). The EP has been fully recorded, mixed and mastered by themselves under the flag of Martijn’s Asymmetry Audio.",
    spotify: "https://spotify.com",
    appleMusic: "https://www.apple.com/de/apple-music/",
    bandcamp: "https://bandcamp.com"
)

let bands = [behemoth, blindGurdian, nephylim]
