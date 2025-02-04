//
//  ChatGPTReplicaView.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 04/02/25.
//

import SwiftUI
// MARK: - Chat Content (ChatGPT Replica) View
struct ChatGPTReplicaView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    @Binding var selectedConversationID: UUID?
    
    @State private var messageText: String = ""
    
    // In this version the AI response comes from the backend.
    var body: some View {
        VStack(spacing: 0) {
            // Scrollable Chat Content
            ZStack {
                if currentConversation?.messages.isEmpty ?? true {
                    VStack {
                        Spacer()
                        Image("bg")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(currentConversation?.messages ?? []) { msg in
                                MessageBubble(message: msg)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            
            // Input Area
            MessageInputView(messageText: $messageText, sendMessage: sendMessage)
                .padding(.bottom, safeAreaBottomInset())
        }
        .background(Color.white)
    }
    
    private var currentConversation: Conversation? {
        chatVM.conversations.first { $0.id == selectedConversationID }
    }
    
    private func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, selectedConversationID != nil else { return }
        Task {
            await chatVM.sendMessage(trimmed)
            messageText = ""
        }
    }
    
    private func safeAreaBottomInset() -> CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
}
