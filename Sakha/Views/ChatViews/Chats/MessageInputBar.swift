//
//  MessageInputBar.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 27/09/24.
//

import SwiftUI

struct MessageInputBar: View {
    @Binding var inputText: String
    var sendAction: () -> Void

    var body: some View {
        HStack {
            TextField("Type a message...", text: $inputText, axis: .vertical)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .onSubmit {
                    sendAction()
                }

            Button(action: {
                sendAction()
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                    .padding(12)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
    }
}
