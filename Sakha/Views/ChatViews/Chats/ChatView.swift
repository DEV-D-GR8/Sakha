//
//  ChatView.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 27/09/24.
//


import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach($viewModel.conversation.messages) { message in
                            MessageRow(message: message)
                                .padding(.vertical, 4)
                                .id(message.id)
                        }
                        if viewModel.isAssistantTyping {
                            TypingIndicator()
                                .padding(.vertical, 4)
                        }
                    }
                }
                .onChange(of: $viewModel.conversation.messages.count) { _ in
                    if let lastMessage = $viewModel.conversation.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            MessageInputBar(inputText: $viewModel.inputText, sendAction: viewModel.sendMessage)
                .padding()
        }
        .navigationTitle($viewModel.conversation.title)
        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//                    viewModel.loadMessages()
//                }
    }
}

struct TypingIndicator: View {
    @State private var dotCount = 0
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.blue)
            Text(String(repeating: ".", count: dotCount % 4))
                .onReceive(timer) { _ in
                    dotCount += 1
                }
        }
        .padding(.horizontal)
    }
}
