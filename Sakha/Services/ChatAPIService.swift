//
//  ChatAPIService.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 04/02/25.
//


import Foundation

final class ChatAPIService {
    static let shared = ChatAPIService()
    
    // Base URL for your backend API (e.g., your AWS API Gateway endpoint)
    private let baseURL = URL(string: "https://api.sakha.com/api")!
    
    // Retrieve your Firebase JWT (or AWS Cognito token) from secure storage.
    private var authToken: String? {
        // For production, load securely from Keychain.
        return UserDefaults.standard.string(forKey: "FirebaseAuthToken")
    }
    
    private init() {}
    
    // MARK: - Create a New Conversation (ChatSession)
    func createConversation(language: String = "en") async throws -> Conversation {
        let url = baseURL.appendingPathComponent("chats/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let body: [String: Any] = ["language": language]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
        let conversation = try JSONDecoder().decode(Conversation.self, from: data)
        return conversation
    }
    
    // MARK: - Load All Conversations for the User
    func loadConversations() async throws -> [Conversation] {
        let url = baseURL.appendingPathComponent("chats/")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let conversations = try JSONDecoder().decode([Conversation].self, from: data)
        return conversations
    }
    
    // MARK: - Load Messages for a Given Conversation
    func loadMessages(for conversationID: UUID) async throws -> [ChatMessage] {
        let url = baseURL.appendingPathComponent("chats/\(conversationID.uuidString)/messages/")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let messages = try JSONDecoder().decode([ChatMessage].self, from: data)
        return messages
    }
    
    // MARK: - Send a Message (User input) and Retrieve Updated Message List
    func sendMessage(for conversationID: UUID, text: String) async throws -> [ChatMessage] {
        let url = baseURL.appendingPathComponent("chats/\(conversationID.uuidString)/messages/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let body: [String: Any] = ["text": text]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
        let messages = try JSONDecoder().decode([ChatMessage].self, from: data)
        return messages
    }
}
