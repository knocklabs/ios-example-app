//
//  Utils.swift
//  Knock Example
//
//  Created by Diego on 16/05/23.
//

import Foundation
import Knock

class Utils {
    private static var internalKnockClient: Knock?
    
    static let publishableKey = ""
    static let userId = ""
    static let inAppChannelId = ""
    static let apnsChannelId = ""

    static func myKnockClient() -> Knock {
        if internalKnockClient != nil {
            return internalKnockClient!
        }
        else {
            internalKnockClient = try! Knock(publishableKey: publishableKey, userId: userId)
            internalKnockClient!.feedManager = Knock.FeedManager(client: internalKnockClient!, feedId: inAppChannelId)

            return internalKnockClient!
        }
    }
}
