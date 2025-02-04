//
//  AuthViewModel.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 27/09/24.
//

import SwiftUI
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    enum AuthState {
        case undefined, signedOut, signedIn
    }

    @Published var isUserAuthenticated: AuthState = .undefined
    @Published var user: User?

    private var handle: AuthStateDidChangeListenerHandle?
    private let rememberMeKey = "rememberMe"
    private var rememberMe: Bool {
        get { UserDefaults.standard.bool(forKey: rememberMeKey) }
        set { UserDefaults.standard.set(newValue, forKey: rememberMeKey) }
    }

    init() {
        listenToAuthState()
    }

    private func listenToAuthState() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user, user.isEmailVerified || !self.isPasswordUser(user) {
                self.user = user
                self.isUserAuthenticated = .signedIn
            } else {
                self.user = nil
                self.isUserAuthenticated = .signedOut
            }
        }
    }

    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signOutIfNeeded() {
        if !rememberMe {
            signOut()
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            isUserAuthenticated = .signedOut
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    func setRememberMe(_ value: Bool) {
        rememberMe = value
    }

    private func isPasswordUser(_ user: User) -> Bool {
        user.providerData.contains { $0.providerID == "password" }
    }

    func reloadUser(completion: @escaping (Error?) -> Void) {
        user?.reload(completion: completion)
    }
}
