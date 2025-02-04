////
////  ConversationsViewModel.swift
////  Sakha
////
////  Created by Dev Asheesh Chopra on 27/09/24.
////
//
////import SwiftUI
////import Combine
////
////class ConversationsViewModel: ObservableObject {
////    @Published var conversations: [Conversation] = []
////
////    init() {
////        loadConversations()
////    }
////
////    func loadConversations() {
////        // Load conversations from local storage or backend
////        // For now, we'll use some dummy data
////        conversations = [
////            Conversation(title: "Chat with Assistant", messages: [
////                Message(text: "Hello!", sender: .assistant),
////                Message(text: "Hi there!", sender: .user)
////            ], lastUpdated: Date().addingTimeInterval(-3600)),
////            Conversation(title: "Previous Conversation", messages: [
////                Message(text: "How can I help you?", sender: .assistant),
////                Message(text: "Tell me a joke.", sender: .user),
////                Message(text: "Why did the chicken cross the road?", sender: .assistant)
////            ], lastUpdated: Date().addingTimeInterval(-7200))
////        ]
////    }
////
////    func createNewConversation() -> Conversation {
////        let newConversation = Conversation()
////        conversations.insert(newConversation, at: 0)
////        return newConversation
////    }
////}
//
//
//
//
//import SwiftUI
//import Combine
//import FirebaseAuth
//
//class ConversationsViewModel: ObservableObject {
//    @Published var conversations: [Conversation] = []
//
//    func loadConversations() {
//        guard let currentUser = Auth.auth().currentUser else {
//            print("User not logged in")
//            return
//        }
//
//        currentUser.getIDToken { idToken, error in
//            if let error = error {
//                print("Error getting ID token: \(error)")
//                return
//            }
//
//            guard let idToken = idToken else {
//                print("No ID token")
//                return
//            }
//
//            guard let url = URL(string: "http://127.0.0.1:8000/api/conversations/") else { return }
//
//            var request = URLRequest(url: url)
//            request.httpMethod = "GET"
//            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
//
//            URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    print("Error fetching conversations: \(error)")
//                    return
//                }
//
//                guard let data = data else {
//                    print("No data returned from backend")
//                    return
//                }
//
//                do {
//                    let decoder = JSONDecoder()
//                    decoder.dateDecodingStrategy = .iso8601
//                    let conversationMetas = try decoder.decode([ConversationMeta].self, from: data)
//
//                    // Map ConversationMeta to Conversation
////                    let fetchedConversations = conversationMetas.map { meta -> Conversation in
////                        return Conversation(
////                            id: UUID(uuidString: meta.id) ?? UUID(),
////                            title: meta.title,
////                            messages: [],  // Messages will be loaded when opening the chat
////                            lastUpdated: meta.lastUpdated
////                        )
////                    }
//                    let fetchedConversations = conversationMetas.map { meta -> Conversation in
//                        return Conversation(
//                            id: meta.id,  // Now a String
//                            title: meta.title,
//                            messages: [],  // Messages will be loaded when opening the chat
//                            lastUpdated: meta.lastUpdated
//                        )
//                    }
//
//                    DispatchQueue.main.async {
//                        self.conversations = fetchedConversations
//                    }
//
//                } catch {
//                    print("Error parsing JSON: \(error)")
//                }
//            }.resume()
//        }
//    }
//    
//    func deleteConversation(at offsets: IndexSet) {
//        guard let index = offsets.first else { return }
//        let conversation = conversations[index]
//
//        guard let currentUser = Auth.auth().currentUser else {
//            print("User not logged in")
//            return
//        }
//
//        currentUser.getIDToken { idToken, error in
//            if let error = error {
//                print("Error getting ID token: \(error)")
//                return
//            }
//
//            guard let idToken = idToken else {
//                print("No ID token")
//                return
//            }
//
//            let conversationID = conversation.id
//            guard let url = URL(string: "http://127.0.0.1:8000/api/conversations/\(conversationID)/delete/") else { return }
//
//            var request = URLRequest(url: url)
//            request.httpMethod = "DELETE"
//            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
//
//            URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    print("Error deleting conversation: \(error)")
//                    return
//                }
//
//                // Remove conversation from local list
//                DispatchQueue.main.async {
//                    self.conversations.remove(atOffsets: offsets)
//                }
//            }.resume()
//        }
//    }
//    func addConversation(_ conversation: Conversation) {
//        DispatchQueue.main.async {
//            self.conversations.insert(conversation, at: 0)
//        }
//    }
//
//
//
////    func createNewConversation() -> Conversation {
////        let newConversation = Conversation()
////        conversations.insert(newConversation, at: 0)
////        return newConversation
////    }
//    func createNewConversation() -> Conversation {
//        let newConversation = Conversation(id: UUID().uuidString, title: "New Chat", messages: [], lastUpdated: Date())
//            conversations.insert(newConversation, at: 0)
//            // Persist conversations if necessary
//            return newConversation
//        }
//}
//
//// Define ConversationMeta to match the response from the backend
//struct ConversationMeta: Codable {
//    let id: String
//    let title: String
//    let lastUpdated: Date
//}


import SwiftUI
import Combine
import FirebaseAuth

class ConversationsViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []

    func loadConversations() {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }

        currentUser.getIDToken { idToken, error in
            if let error = error {
                print("Error getting ID token: \(error)")
                return
            }

            guard let idToken = idToken else {
                print("No ID token")
                return
            }

            guard let url = URL(string: "http://127.0.0.1:8000/api/conversations/") else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error fetching conversations: \(error)")
                    return
                }

                guard let data = data else {
                    print("No data returned from backend")
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let conversationMetas = try decoder.decode([ConversationMeta].self, from: data)

                    // Map ConversationMeta to Conversation
                    let fetchedConversations = conversationMetas.map { meta -> Conversation in
                        return Conversation(
                            id: UUID(uuidString: meta.id) ?? UUID(),
                            title: meta.title,
                            messages: [],  // Messages will be loaded when opening the chat
                            lastUpdated: meta.lastUpdated
                        )
                    }

                    DispatchQueue.main.async {
                        self.conversations = fetchedConversations
                    }

                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }.resume()
        }
    }

//    func createNewConversation() -> Conversation {
//        let newConversation = Conversation()
//        conversations.insert(newConversation, at: 0)
//        return newConversation
//    }
    func createNewConversation() -> Conversation {
            let newConversation = Conversation(id: UUID(), title: "New Chat", messages: [], lastUpdated: Date())
            conversations.insert(newConversation, at: 0)
            // Persist conversations if necessary
            return newConversation
        }
}

// Define ConversationMeta to match the response from the backend
struct ConversationMeta: Codable {
    let id: String
    let title: String
    let lastUpdated: Date
}
