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
    
//    override init() {
//        Task {
//            try? await Knock.shared.setup(publishableKey: Utils.publishableKey, pushChannelId: Utils.apnsChannelId, options: .init(hostname: Utils.hostname, loggingOptions: .verbose))
//            let _ = try? await Knock.shared.requestNotificationPermission()
//        }
//        super.init()
//    }
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Task {
            try? await Knock.shared.setup(publishableKey: Utils.publishableKey, pushChannelId: Utils.apnsChannelId, options: .init(hostname: Utils.hostname, loggingOptions: .verbose))
        }        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func pushNotificationTapped(userInfo: [AnyHashable : Any]) {
        super.pushNotificationTapped(userInfo: userInfo)
        if let deeplink = userInfo["deep_link"] as? String, let url = URL(string: deeplink) {
            UIApplication.shared.open(url)
        }
    }
    
    override func pushNotificationDeliveredInForeground(notification: UNNotification) -> UNNotificationPresentationOptions {
        let options = super.pushNotificationDeliveredInForeground(notification: notification)
        return [options]
    }
    
    // TODO: test to make sure this works
    override func pushNotificationDeliveredSilently(userInfo: [AnyHashable : Any], completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.noData)
    }
}


