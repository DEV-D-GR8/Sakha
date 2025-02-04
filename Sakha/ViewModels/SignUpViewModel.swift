//
//  SignUpViewModel.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 27/09/24.
//

import SwiftUI
import FirebaseAuth
import Firebase
import GoogleSignIn

class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage = ""
    @Published var showAlert = false
    @Published var isVerificationSent = false
    @Published var isLoading = false

    @Published var emailValidationMessage: String?
    @Published var passwordValidationMessage: String?
    @Published var confirmPasswordValidationMessage: String?

    private var signInWithAppleCoordinator: SignInWithAppleCoordinator?

    func isFormValid() -> Bool {
        isValidEmail(email) &&
        validatePassword(password) == nil &&
        password == confirmPassword
    }

    func signUpWithEmail(completion: @escaping (Bool) -> Void) {
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address."
            showAlert = true
            completion(false)
            return
        }

        if let validationError = validatePassword(password) {
            errorMessage = validationError
            showAlert = true
            completion(false)
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            showAlert = true
            completion(false)
            return
        }

        isLoading = true

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showAlert = true
                completion(false)
            } else {
                authResult?.user.sendEmailVerification { error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        self.showAlert = true
                        completion(false)
                    } else {
                        self.isVerificationSent = true
                        self.showAlert = true
                        do {
                            try Auth.auth().signOut()
                        } catch {
                            print("Error signing out: \(error.localizedDescription)")
                        }
                        completion(true)
                    }
                }
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

    // MARK: - Validation Functions

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }

    func validatePassword(_ password: String) -> String? {
        if password.count < 6 {
            return "Password must be at least 6 characters long."
        }
        // Additional password validation...
        return nil
    }
}
