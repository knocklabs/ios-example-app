//
//  ContentView.swift
//  Knock Example
//
//  Created by Matt Gardner on 2/6/24.
//

import SwiftUI
import Knock

struct ContentView: View {
    @State private var authViewModel = AuthenticationViewModel()

    var body: some View {
        Group {
            if authViewModel.isSignedIn {
                MainView()
                    .environment(authViewModel)
            } else {
                SignInView()
                    .environment(authViewModel)
            }
        }
        .task {
            await authViewModel.signIn(userId: Utils.userId)
        }
    }
}

#Preview {
    ContentView()
}
