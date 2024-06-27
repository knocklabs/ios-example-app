//
//  AppDelegate.swift
//  Knock Example
//
//  Created by Diego on 16/05/23.
//

import Foundation
import UIKit
import Knock

class AppDelegate: KnockAppDelegate {
        
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Task {
            try? await Knock.shared.setup(publishableKey: Utils.publishableKey, pushChannelId: Utils.apnsChannelId, options: .init(hostname: Utils.hostname, loggingOptions: .verbose))
            await Knock.shared.signIn(userId: Utils.userId, userToken: nil)
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
        
    override func pushNotificationTapped(userInfo: [AnyHashable : Any]) {
        super.pushNotificationTapped(userInfo: userInfo)
        if let deeplink = userInfo["link"] as? String, let url = URL(string: deeplink) {
            UIApplication.shared.open(url)
        }
    }
    
    override func pushNotificationDeliveredInForeground(notification: UNNotification) -> UNNotificationPresentationOptions {
        let options = super.pushNotificationDeliveredInForeground(notification: notification)
        // Handle push notification here
        return [options]
    }
    
    override func pushNotificationDeliveredSilently(userInfo: [AnyHashable : Any], completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Handle silent push notification here
        completionHandler(.noData)
    }
}
