//
//  Knock_ExampleApp.swift
//  Knock Example
//
//  Created by Diego on 16/05/23.
//

import SwiftUI

@main
struct Knock_ExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
    }
}
