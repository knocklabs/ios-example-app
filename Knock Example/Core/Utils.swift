//
//  Utils.swift
//  Knock Example
//
//  Created by Diego on 16/05/23.
//

import Foundation
import Knock

struct Team {
    let id: String
    let name: String
}

class Utils {    
    static let publishableKey = ""
    static let userId = ""
    static let inAppChannelId = ""
    static let apnsChannelId = ""
    static let hostname = "https://api.knock.app"
    static let teams = [Team(id: "team-a", name: "Team A"), Team(id: "team-b", name: "Team B")]
}
