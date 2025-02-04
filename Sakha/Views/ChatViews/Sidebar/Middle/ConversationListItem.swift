//
//  ConversationListItem.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 04/02/25.
//

import SwiftUI
// MARK: - Conversation List Item
struct ConversationListItem: View {
    let conversation: Conversation
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(conversation.name)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}


