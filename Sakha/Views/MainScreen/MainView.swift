//
//  MainView.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 04/02/25.
//


import SwiftUI

// MARK: - Main View with Slide-Over Chat List
struct MainView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    @State private var showingChatList = false
    @State private var selectedConversationID: UUID?
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Chat content view
            ChatGPTReplicaView(selectedConversationID: $selectedConversationID)
                .environmentObject(chatVM)
            
            // Top Bar overlay
            TopBarView(showingChatList: $showingChatList, selectedConversationID: $selectedConversationID)
                .zIndex(3)
                .environmentObject(chatVM)
            
            // Slide-over chat list
            if showingChatList {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .zIndex(1)
                    .transition(.opacity)
                    .onTapGesture { showingChatList = false }
                
                ChatListView(selectedID: $selectedConversationID, isVisible: $showingChatList)
                    .zIndex(5)
                    .transition(.move(edge: .leading))
            }
        }
    }
}