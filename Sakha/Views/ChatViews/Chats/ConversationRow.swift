//
//  ConversationRow.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 04/02/25.
//


struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        VStack(alignment: .leading) {
            Text(conversation.title)
                .font(.headline)
            if let lastMessage = conversation.messages.last {
                Text(lastMessage.text)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
    }
}
