//
//  TopBarView.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 04/02/25.
//


// MARK: - Top Bar View
import SwiftUI

struct TopBarView: View {
    @Binding var showingChatList: Bool
    @Binding var selectedConversationID: UUID?
    @EnvironmentObject var chatVM: ChatViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showingChatList.toggle()
                    }
                } label: {
                    Image(systemName: "line.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("Sakha")
                    .font(.title.bold())
                
                Spacer()
                
                Button {
                    Task {
                        await chatVM.createNewConversation()
                        // Immediately select the new conversation.
                        selectedConversationID = chatVM.selectedConversation?.id
                    }
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .overlay(Divider(), alignment: .bottom)
            
            Spacer()
        }
    }
}
