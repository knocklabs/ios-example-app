//
//  AppDelegate.swift
//  Knock Example
//
//  Created by Diego on 16/05/23.
//

import Foundation
import UIKit
import Knock

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var pushToken: String? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                DispatchQueue.main.sync {
                    print("authorized to show alerts")
                    
                    UIApplication.shared.registerForRemoteNotifications()
                    
                    let category = UNNotificationCategory(identifier: "my-custom-dismiss-action-category", actions: [], intentIdentifiers: [], options: .customDismissAction)
                    UNUserNotificationCenter.current().setNotificationCategories([category])
                }
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("\n\n\nSuccessfully registered for notifications!")
        
        // 1. Convert device token to string
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        // 2. Print device token to use for PNs payloads
        print("Device Token: \(token)")
        
        savePushToken(token: token)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("\n\n\ndidReceiveRemoteNotification")

        let content = userInfo

        if let notification_id = content["dismiss_notification_id"] as? String {
            print("dismissed notification_id: \(notification_id)")
            removeNotification(notification_id: notification_id)
        }

        completionHandler(.noData)
    }
    
    // This method will be called when app received push notifications in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("center willPresent notification:")
        print(notification)
        
        if let notification_id = notification.request.content.userInfo["knock_message_id"] as? String {
            // marking notification as seen, since it was shown when the app was on the foreground, presumably when the user was using the app
            Utils.myKnockClient().updateMessageStatus(messageId: notification_id, status: .seen) { result in
                switch result {
                case .success(_):
                    print("message marked as seen")
                case .failure(let error):
                    print("error marking message as seen")
                    print(error)
                }
            }
        }
        
        completionHandler([.banner, .sound, .list])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("\n\n\ndidReceiveNotificationResponse:")
        print(response)
        
        let userInfo = response.notification.request.content.userInfo
        
        if let notification_id = userInfo["knock_message_id"] as? String {
            if response.actionIdentifier == UNNotificationDismissActionIdentifier {
                print("dismissed notification_id: \(notification_id)")
                Utils.myKnockClient().updateMessageStatus(messageId: notification_id, status: .read) { result in
                    switch result {
                    case .success(_):
                        print("message marked as read")
                    case .failure(let error):
                        print("error marking message as read")
                        print(error)
                    }
                }
            }
            else {
                print("action on notification: \(notification_id)")
                Utils.myKnockClient().updateMessageStatus(messageId: notification_id, status: .interacted) { result in
                    switch result {
                    case .success(_):
                        print("message marked as interacted")
                    case .failure(let error):
                        print("error marking message as interacted")
                        print(error)
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
        print("AppDelegate removeNotification: \(notification_id)")
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification_id])
    }
}
