//
//  ChatListView.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 04/02/25.
//

import SwiftUI
// MARK: - Chat List View
struct ChatListView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    @Binding var selectedID: UUID?
    @Binding var isVisible: Bool
    @State private var searchText = ""
    
    var filteredConversations: [Conversation] {
        if searchText.isEmpty {
            return chatVM.conversations
        }
        return chatVM.conversations.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with Search Bar
            VStack(spacing: 0) {
                HStack {
                    Text("Messages")
                        .font(.title2.bold())
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring()) {
                            isVisible = false
                        }
                    } label: {
                        Text("Close")
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                SearchBarView(text: $searchText)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }
            .background(Color(.systemBackground))
            
            // Conversation List
            List {
                ForEach(filteredConversations) { conv in
                    ConversationListItem(conversation: conv) {
                        selectedID = conv.id
                        withAnimation {
                            isVisible = false
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .frame(width: 300)
        .background(Color(.systemBackground))
    }
}
