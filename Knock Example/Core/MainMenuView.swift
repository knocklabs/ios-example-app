//
//  MainMenuView.swift
//  Knock Example
//
//  Created by Diego on 16/05/23.
//

import SwiftUI

struct MainMenuView: View {
    var body: some View {
        TabView {
            MessageComposeView()
                .tabItem {
                    Label("Messages", systemImage: "envelope")
                }
            PreferencesView()
                .tabItem {
                    Label("Preferences", systemImage: "gear")
                }
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
