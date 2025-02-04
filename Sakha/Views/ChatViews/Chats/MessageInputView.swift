//
//  MessageInputView.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 04/02/25.
//

import SwiftUI
// MARK: - Message Input View
struct MessageInputView: View {
    @Binding var messageText: String
    let sendMessage: () -> Void
    
    var body: some View {
        HStack {
            TextField("Type a message...", text: $messageText)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(25)
            
            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color.white.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: -2))
    }
}
