//
//  MessageBubble.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 04/02/25.
//

import SwiftUI
// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
            } else {
                HStack(alignment: .top) {
                    Image("krishna")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                    
                    Text(message.text)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)
                        .font(.system(size: 16))
                        .textSelection(.enabled)
                }
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}
