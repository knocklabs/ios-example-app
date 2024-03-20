//
//  AuthenticationViewModel.swift
//  Knock Example
//
//  Created by Matt Gardner on 2/5/24.
//

import Foundation
import Knock

@Observable class AuthenticationViewModel {
    var isSignedIn: Bool!
    
    init() {
        Knock.shared.isAuthenticated() { result in
            self.isSignedIn = result
        }
    }
    
    func signIn(userId: String) async {
        await Knock.shared.signIn(userId: userId, userToken: nil)
        isSignedIn = true
    }
}
