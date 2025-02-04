//
//  SignUpView.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 27/09/24.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = SignUpViewModel()
    @ObservedObject private var keyboardResponder = KeyboardResponder()
    @State private var showAlert: Bool = false
    @State private var navigateToLogin = false

    var body: some View {
        ZStack {
            Color("BgColor").edgesIgnoringSafeArea(.all)
            VStack {
                NavigationLink(destination: LoginView().environmentObject(authViewModel), isActive: $navigateToLogin) {
                    EmptyView()
                }

                ScrollView(showsIndicators: false) {
                    VStack {
                        Text("Sign Up")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 30)

                        // Social login buttons
//                        SocialLoginButton(image: Image(systemName: "applelogo"), text: Text("Sign in with Apple"), action: {
//                            // Handle Apple Sign-In
//                        })
//
//                        SocialLoginButton(image: Image(systemName: "g.circle"), text: Text("Sign in with Google").foregroundColor(Color("PrimaryColor")), action: {
//                            // Handle Google Sign-In
//                        })
//                        .padding(.vertical)
                        
                        // Sign in with Apple Button
                                                SocialLoginButton(image: Image(systemName: "applelogo"), text: Text("Sign in with Apple"), action: {
                                                    viewModel.handleSignInWithApple { success in
                                                        if success {
                                                            authViewModel.setRememberMe(true)
                                                            authViewModel.isUserAuthenticated = .signedIn
                                                        }
                                                    }
                                                })

                                                // Sign in with Google Button
                                                SocialLoginButton(image: Image(systemName: "g.circle"), text: Text("Sign in with Google").foregroundColor(Color("PrimaryColor")), action: {
                                                    if let rootVC = UIApplication.shared.getRootViewController() {
                                                        viewModel.handleSignInWithGoogle(presenting: rootVC) { success in
                                                            if success {
                                                                authViewModel.setRememberMe(true)
                                                                authViewModel.isUserAuthenticated = .signedIn
                                                            }
                                                        }
                                                    }
                                                })
                                                .padding(.vertical)

                        Divider().padding(.bottom)

                        Text("or register using email")
                            .foregroundColor(Color.black.opacity(0.4))

                        // Email Field
                        TextField("Email address", text: $viewModel.email)
                            .font(.title3)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(50)
                            .shadow(color: Color.black.opacity(0.08), radius: 60, x: 0, y: 16)
                            .padding(.vertical)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.emailAddress)
                            .onChange(of: viewModel.email) { _ in
                                viewModel.emailValidationMessage = viewModel.isValidEmail(viewModel.email) ? nil : "Please enter a valid email address."
                            }

                        if let emailValidationMessage = viewModel.emailValidationMessage {
                            Text(emailValidationMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.bottom, 5)
                        }

                        // Password Field
                        SecureField("Password", text: $viewModel.password)
                            .font(.title3)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(50)
                            .shadow(color: Color.black.opacity(0.08), radius: 60, x: 0, y: 16)
                            .padding(.bottom)
                            .onChange(of: viewModel.password) { _ in
                                viewModel.passwordValidationMessage = viewModel.validatePassword(viewModel.password)
                            }

                        if let passwordValidationMessage = viewModel.passwordValidationMessage {
                            Text(passwordValidationMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.bottom, 5)
                        }

                        // Confirm Password Field
                        SecureField("Confirm Password", text: $viewModel.confirmPassword)
                            .font(.title3)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(50)
                            .shadow(color: Color.black.opacity(0.08), radius: 60, x: 0, y: 16)
                            .padding(.bottom)
                            .onChange(of: viewModel.confirmPassword) { _ in
                                viewModel.confirmPasswordValidationMessage = viewModel.password == viewModel.confirmPassword ? nil : "Passwords do not match."
                            }

                        if let confirmPasswordValidationMessage = viewModel.confirmPasswordValidationMessage {
                            Text(confirmPasswordValidationMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.bottom, 5)
                        }

                        // Sign Up Button
//                        Button(action: {
//                            viewModel.signUpWithEmail { success in
//                                if success {
//                                    showAlert = true
//                                } else {
//                                    showAlert = true
//                                }
//                            }
//                        }) {
//                            PrimaryButton(title: "Sign Up")
//                        }
//                        .disabled(!viewModel.isFormValid())
                        
                        Button(action: {
                                                    viewModel.signUpWithEmail { success in
                                                        if success {
                                                            navigateToLogin = true
                                                        }
                                                    }
                                                }) {
                                                    PrimaryButton(title: "Sign Up")
                                                }
                                                .disabled(!viewModel.isFormValid())
                    }
                    .padding()
                    .padding(.bottom, keyboardResponder.currentHeight)
                    .animation(.easeOut(duration: 0.16))

                    Spacer()
                    Divider()
                    Spacer()
                    Text("You are completely safe.")
                    Text("Read our Terms & Conditions.")
                        .foregroundColor(Color("PrimaryColor"))
                    Spacer()
                }
            }
            .alert(isPresented: $showAlert) {
                if viewModel.isVerificationSent {
                    return Alert(
                        title: Text("Verification Email Sent"),
                        message: Text("Please check your email and verify your account before logging in."),
                        dismissButton: .default(Text("OK"), action: {
                            navigateToLogin = true
                        })
                    )
                } else {
                    return Alert(
                        title: Text("Error"),
                        message: Text(viewModel.errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                ProgressView()
            }
        }
    }
}
