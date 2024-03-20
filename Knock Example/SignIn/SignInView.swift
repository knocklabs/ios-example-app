//
//  SignInView.swift
//  Knock Example
//
//  Created by Matt Gardner on 2/5/24.
//

import SwiftUI
import Knock

struct SignInView: View {
    @Environment(AuthenticationViewModel.self) var authViewModel
    @State var userId: String = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Spacer()
                TextField("User Id", text: $userId)
                    .textContentType(.username)
                    .tint(.primary)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
                
                Button("SignIn") {
                    Task {
                        await authViewModel.signIn(userId: userId)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Sign In")
        }
    }
}

#Preview {
    let authViewModel = AuthenticationViewModel()
    authViewModel.isSignedIn = false
    return SignInView().environment(authViewModel)
}
