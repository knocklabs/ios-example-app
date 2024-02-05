//
//  AppDelegate.swift
//  Knock Example
//
//  Created by Diego on 16/05/23.
//

import Foundation
import UIKit
import Knock
import OSLog

class AppDelegate: KnockAppDelegate {
    
    private let logger = Logger(subsystem: "app.knock.ios-example", category: "AppDelegate")
    
    override init() {
        super.init()
        try? Knock.shared.setup(publishableKey: Utils.publishableKey, pushChannelId: Utils.apnsChannelId, hostname: Utils.hostname)
        Task {
            try? await Knock.shared.signIn(userId: Utils.userId, userToken: nil)
            let _ = try? await Knock.shared.requestNotificationPermission()
        }
    }
    
    override func pushNotificationTapped(userInfo: [AnyHashable : Any]) {
        if let deeplink = userInfo["deep_link"] as? String, let url = URL(string: deeplink) {
            UIApplication.shared.open(url)
        }
    }
    
    override func pushNotificationDeliveredInForeground(notification: UNNotification) -> UNNotificationPresentationOptions {
        print("***pushNotificationDeliveredInForeground")
        return [.banner, .sound, .list]
    }
    
    override func pushNotificationDeliveredSilently(userInfo: [AnyHashable : Any], completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("***pushNotificationDeliveredSilently")
        completionHandler(.noData)
    }
}


