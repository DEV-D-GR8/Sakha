//
//  LoginViewModel.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 27/09/24.
//

import SwiftUI
import FirebaseAuth
import Firebase
import GoogleSignIn

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var showAlert = false
    @Published var isLoading = false
    @Published var rememberMe = true

    private var signInWithAppleCoordinator: SignInWithAppleCoordinator?

    func signInWithEmail(completion: @escaping (Bool) -> Void) {
        isLoading = true

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            self.isLoading = false

            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showAlert = true
                completion(false)
            } else if let user = authResult?.user {
                if user.isEmailVerified {
                    completion(true)
                } else {
                    self.errorMessage = "Please verify your email before logging in."
                    self.showAlert = true
                    do {
                        try Auth.auth().signOut()
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                    completion(false)
                }
            }
        }
    }

    func forgotPassword(completion: @escaping (Bool) -> Void) {
        if email.isEmpty {
            errorMessage = "Please enter your email address to reset your password."
            showAlert = true
            completion(false)
            return
        }
        isLoading = true

        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false

            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showAlert = true
                completion(false)
            } else {
                self.errorMessage = "Password reset email sent. Please check your email."
                self.showAlert = true
                completion(true)
            }
        }
    }

    // MARK: - Social Logins

    func handleSignInWithApple(completion: @escaping (Bool) -> Void) {
        signInWithAppleCoordinator = SignInWithAppleCoordinator()
        signInWithAppleCoordinator?.onSignedIn = { [weak self] authResult, error in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showAlert = true
                completion(false)
            } else {
                completion(true)
            }
        }
        isLoading = true
        signInWithAppleCoordinator?.startSignInWithAppleFlow()
    }

    func handleSignInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        isLoading = true

        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [weak self] signInResult, error in
            guard let self = self else { return }
            if let error = error {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.showAlert = true
                completion(false)
                return
            }

            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                self.isLoading = false
                self.errorMessage = "Unable to authenticate with Google."
                self.showAlert = true
                completion(false)
                return
            }

            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { _, error in
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showAlert = true
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
