//
//  ChatViewModel.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 27/09/24.
//

//import SwiftUI
//import Combine
//import FirebaseAuth
//
//class ChatViewModel: ObservableObject {
//    @Published var conversation: Conversation
//    @Published var inputText: String = ""
//    @Published var isAssistantTyping: Bool = false
//
//    private var cancellables = Set<AnyCancellable>()
//
//    init(conversation: Conversation) {
//        self.conversation = conversation
//    }
//
//    func sendMessage() {
//        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedText.isEmpty else { return }
//
//        // Add the user's message
//        let userMessage = Message(text: trimmedText, sender: .user)
//        // Prepare request body
//        var parameters: [String: Any] = [
//            "message": userMessage.text
//        ]
//
//        if self.conversation.id != UUID() {
//            parameters["conversation_id"] = self.conversation.id.uuidString
//        }
//
//        conversation.messages.append(userMessage)
//        conversation.lastUpdated = Date()
//        inputText = ""
//
//        // Send the message to the backend
//        fetchAssistantResponse(userMessage: userMessage)
//    }
//
//    private func fetchAssistantResponse(userMessage: Message) {
//        isAssistantTyping = true
//        guard let url = URL(string: "http://127.0.0.1:8000/api/chat/") else { return }
//
//        // Get the current user
//        guard let currentUser = Auth.auth().currentUser else {
//            print("User not logged in")
//            self.isAssistantTyping = false
//            return
//        }
//
//        // Get ID token
//        currentUser.getIDToken { idToken, error in
//            if let error = error {
//                print("Error getting ID token: \(error)")
//                self.isAssistantTyping = false
//                return
//            }
//
//            guard let idToken = idToken else {
//                print("No ID token")
//                self.isAssistantTyping = false
//                return
//            }
//
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
//
//            // Prepare request body
//            let parameters: [String: Any] = [
//                "conversation_id": self.conversation.id.uuidString,
//                "message": userMessage.text
//            ]
//
//            do {
//                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
//            } catch {
//                print("Error serializing JSON: \(error)")
//                self.isAssistantTyping = false
//                return
//            }
//
//            URLSession.shared.dataTask(with: request) { data, response, error in
//                DispatchQueue.main.async {
//                    self.isAssistantTyping = false
//                }
//
//                if let error = error {
//                    print("Error fetching assistant response: \(error)")
//                    return
//                }
//
//                // Print HTTP response status code
//                if let httpResponse = response as? HTTPURLResponse {
//                    print("HTTP Response Status Code: \(httpResponse.statusCode)")
//                }
//
//                // Print raw data as string
//                if let data = data, let dataString = String(data: data, encoding: .utf8) {
//                    print("Response Data String: \(dataString)")
//                } else {
//                    print("No data returned from backend")
//                }
//
//                do {
//                    guard let data = data else {
//                        print("No data received")
//                        return
//                    }
//
//                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//
//                        if let errorMessage = json["error"] as? String {
//                            print("Backend Error: \(errorMessage)")
//                            // Handle error appropriately (e.g., show an alert to the user)
//                            return
//                        }
//
//                        if let assistantText = json["assistant_response"] as? String,
//                           let conversationID = json["conversation_id"] as? String {
//
//                            DispatchQueue.main.async {
//                                // Update conversation ID if it's a new conversation
//                                if self.conversation.id.uuidString != conversationID {
//                                    self.conversation.id = UUID(uuidString: conversationID) ?? UUID()
//                                }
//
//                                let assistantMessage = Message(text: assistantText, sender: .assistant)
//                                self.conversation.messages.append(assistantMessage)
//                                self.conversation.lastUpdated = Date()
//                            }
//                        } else {
//                            print("Invalid JSON response structure")
//                        }
//                    } else {
//                        print("Invalid JSON response")
//                    }
//                } catch {
//                    print("Error parsing JSON: \(error)")
//                }
//
//            }.resume()
//
//        }
//    }
//}


import Foundation
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var selectedConversation: Conversation?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Loads conversations from the backend.
    func loadConversations() async {
        do {
            isLoading = true
            let convos = try await ChatAPIService.shared.loadConversations()
            self.conversations = convos
            // Optionally select the first conversation.
            if let first = convos.first {
                self.selectedConversation = first
            }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    // Creates a new conversation (chat session) and selects it.
    func createNewConversation(language: String = "en") async {
        do {
            isLoading = true
            let newConv = try await ChatAPIService.shared.createConversation(language: language)
            // Insert new conversation at the beginning.
            self.conversations.insert(newConv, at: 0)
            self.selectedConversation = newConv
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    // Sends a user message and updates the conversation with the full message list.
    func sendMessage(_ text: String) async {
        guard let conv = selectedConversation else { return }
        do {
            isLoading = true
            // Optimistically update UI with the user’s message.
            let userMsg = ChatMessage(id: UUID(), role: .user, text: text)
            if let idx = conversations.firstIndex(where: { $0.id == conv.id }) {
                conversations[idx].messages.append(userMsg)
            }
            // Call the backend; the response should include both user and bot messages.
            let updatedMessages = try await ChatAPIService.shared.sendMessage(for: conv.id, text: text)
            if let idx = conversations.firstIndex(where: { $0.id == conv.id }) {
                conversations[idx].messages = updatedMessages
            }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    // Optionally, you can refresh messages for a conversation.
    func refreshMessages() async {
        guard let conv = selectedConversation else { return }
        do {
            let msgs = try await ChatAPIService.shared.loadMessages(for: conv.id)
            if let idx = conversations.firstIndex(where: { $0.id == conv.id }) {
                conversations[idx].messages = msgs
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
