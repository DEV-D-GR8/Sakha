//
//  SplashScreenView.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 27/09/24.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        NavigationView {
            SplashView()
                .navigationBarHidden(true)
        }
    }
}

struct SplashView: View {
    @State private var isAnimating = false
    @State private var circleExpansion = 0.0
    
    // Controls if the nav links are shown
    @State private var showLinks = false
    
    var body: some View {
        ZStack {
            // Background
            Color.yellow.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            // MAIN FLOATING ANIMATION (unchanged, still repeats forever)
            ZStack {
                CirclesView(circleExpansion: $circleExpansion)
                
                Image("krishna")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                    .position(x: UIScreen.main.bounds.width / 2,
                              y: UIScreen.main.bounds.height / 2.3)
            }
            .offset(y: isAnimating ? -10 : 10)
            .animation(
                Animation.easeInOut(duration: 2).repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                // Krishna floating starts immediately and repeats
                isAnimating = true
            }
            
            // FEATHER ANIMATION (assumed one-time)
            // We'll delay showing links until it finishes
            FeatherAnimationView()
                .onAppear {
                    // If your feather animation is ~2 seconds, wait 2 seconds:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                        withAnimation(.easeInOut) {
                            showLinks = true
                        }
                    }
                }
            
            // VSTACK FOR NAV LINKS
            VStack {
                Spacer()
                Spacer()
                
                // Show only after feather animation completes
                if showLinks {
                    // Appear with a gentle transition from bottom
                    navLinksView
                        .transition(.move(edge: .bottom))
                }
            }
            .padding()
        }
    }
    
    private var navLinksView: some View {
        VStack {
            NavigationLink(destination: LoginView().navigationBarHidden(false)) {
                Text("Login")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color("PrimaryColor"))
                    .padding()
                    .frame(maxWidth: 300)
                    .background(Color.white)
                    .cornerRadius(50.0)
                    .shadow(color: Color.black.opacity(0.08),
                            radius: 60, x: 0, y: 16)
                    .padding(.vertical)
            }
            
            NavigationLink(destination: SignUpView().navigationBarHidden(false)) {
                Text("Sign Up")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color("PrimaryColor"))
                    .padding()
                    .frame(maxWidth: 300)
                    .background(Color.white)
                    .cornerRadius(50.0)
                    .shadow(color: Color.black.opacity(0.08),
                            radius: 60, x: 0, y: 16)
                    .padding(.vertical)
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
