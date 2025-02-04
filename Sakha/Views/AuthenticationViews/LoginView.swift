//
//  LoginView.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 27/09/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = LoginViewModel()
    @ObservedObject private var keyboardResponder = KeyboardResponder()
    @State private var showAlert: Bool = false

    var body: some View {
        ZStack {
            Color("BgColor").edgesIgnoringSafeArea(.all)
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack {
                        Text("Login")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 30)

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

                        // Password Field
                        SecureField("Password", text: $viewModel.password)
                            .font(.title3)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(50)
                            .shadow(color: Color.black.opacity(0.08), radius: 60, x: 0, y: 16)
                            .padding(.bottom)

                        // Remember Me Toggle
                        Toggle("Stay signed in", isOn: $viewModel.rememberMe)
                            .padding()

                        // Login Button
                        Button(action: {
                            viewModel.signInWithEmail { success in
                                if success {
                                    authViewModel.setRememberMe(viewModel.rememberMe)
                                    authViewModel.isUserAuthenticated = .signedIn
                                } else {
                                    showAlert = true
                                }
                            }
                        }) {
                            PrimaryButton(title: "Login")
                        }
                        .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
                        .padding(.top)

                        // Forgot Password Button
                        Button(action: {
                            viewModel.forgotPassword { _ in
                                showAlert = true
                            }
                        }) {
                            Text("Forgot Password?")
                                .foregroundColor(Color("PrimaryColor"))
                        }
                        .padding(.top)

                        // OR Divider
                        HStack {
                            Divider().frame(height: 1).background(Color.gray)
                            Text("OR")
                            Divider().frame(height: 1).background(Color.gray)
                        }
                        .padding()

                        // Social login buttons
//                        SocialLoginButton(image: Image(systemName: "applelogo"), text: Text("Sign in with Apple"), action: {
//                            // Handle Apple Sign-In
//                        })
//
//                        SocialLoginButton(image: Image(systemName: "g.circle"), text: Text("Sign in with Google").foregroundColor(Color("PrimaryColor")), action: {
//                            // Handle Google Sign-In
//                        })
//                        .padding(.vertical)
                        
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
                        
                    }
                    .padding()
                    .padding(.bottom, keyboardResponder.currentHeight)
                    .animation(.easeOut(duration: 0.16))
                }
                Spacer()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
            }
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                ProgressView()
            }
        }
    }
}
