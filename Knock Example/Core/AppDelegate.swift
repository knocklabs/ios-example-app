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

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var pushToken: String? = nil
    
    private let logger = Logger(subsystem: "app.knock.ios-example", category: "AppDelegate")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                self.logger.error("error requesting notifications authorization: \(error.localizedDescription)")
            }
            else {
                DispatchQueue.main.sync {
                    self.logger.debug("authorized to show alerts")
                    
                    UIApplication.shared.registerForRemoteNotifications()
                    
                    let category = UNNotificationCategory(identifier: "my-custom-dismiss-action-category", actions: [], intentIdentifiers: [], options: .customDismissAction)
                    UNUserNotificationCenter.current().setNotificationCategories([category])
                }
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        logger.debug("Successfully registered for notifications!")
        
        // 1. Convert device token to string
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        // 2. Print device token to use for PNs payloads
        logger.debug("Device Token: \(token)")
        
        savePushToken(token: token)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logger.error("Failed to register for notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        logger.debug("didReceiveRemoteNotification")

        let content = userInfo

        if let notification_id = content["dismiss_notification_id"] as? String {
            logger.debug("dismissed notification_id: \(notification_id)")
            removeNotification(notification_id: notification_id)
        }

        completionHandler(.noData)
    }
    
    // This method will be called when app received push notifications in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        logger.debug("userNotificationCenter willPresent notification: \(notification)")
        
        if let notification_id = notification.request.content.userInfo["knock_message_id"] as? String {
            // marking notification as seen, since it was shown when the app was on the foreground, presumably when the user was using the app
            Utils.myKnockClient().updateMessageStatus(messageId: notification_id, status: .seen) { result in
                switch result {
                case .success(_):
                    self.logger.debug("message marked as seen")
                case .failure(let error):
                    self.logger.error("error marking message as seen: \(error.localizedDescription)")
                }
            }
        }
        
        completionHandler([.banner, .sound, .list])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        logger.debug("didReceiveNotificationResponse: \(response)")
        
        let userInfo = response.notification.request.content.userInfo
        
        if let notification_id = userInfo["knock_message_id"] as? String {
            if response.actionIdentifier == UNNotificationDismissActionIdentifier {
                logger.debug("dismissed notification_id: \(notification_id)")
                Utils.myKnockClient().updateMessageStatus(messageId: notification_id, status: .read) { result in
                    switch result {
                    case .success(_):
                        self.logger.debug("message marked as read")
                    case .failure(let error):
                        self.logger.error("error marking message as read: \(error.localizedDescription)")
                    }
                }
            }
            else {
                logger.debug("action on notification: \(notification_id)")
                Utils.myKnockClient().updateMessageStatus(messageId: notification_id, status: .interacted) { result in
                    switch result {
                    case .success(_):
                        self.logger.debug("message marked as interacted")
                    case .failure(let error):
                        self.logger.error("error marking message as interacted: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        completionHandler()
    }
    
    func savePushToken(token: String) {
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: "device_push_token")
        self.pushToken = token
    }
    
    private func removeNotification(notification_id: String) {
        logger.debug("AppDelegate removeNotification: \(notification_id)")
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification_id])
    }
}
