//
//  MessageRowView.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 27/09/24.
//

import SwiftUI

struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            if message.sender == .assistant {
                // Assistant's message on the left
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.blue)
                VStack(alignment: .leading) {
                    Text(message.text)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                }
                Spacer()
            } else {
                // User's message on the right
                Spacer()
                VStack(alignment: .trailing) {
                    Text(message.text)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }
}
