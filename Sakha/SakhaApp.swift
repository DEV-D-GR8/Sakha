//
//  SakhaApp.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 24/09/24.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct SakhaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var chatVM = ChatViewModel()
    @StateObject var authViewModel = AuthViewModel()
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        
        WindowGroup {
                    if authViewModel.isUserAuthenticated == .signedIn {
                        MainView()
                            .environmentObject(chatVM)
                            .task {
                                await chatVM.loadConversations()
                            }
                    } else {
                        ContentView()
                            .environmentObject(authViewModel)
                    }
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .background {
                        authViewModel.signOutIfNeeded()
                    }
                }
    }
}
