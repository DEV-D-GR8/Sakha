//////
//////  Conversation.swift
//////  Sakha
//////
//////  Created by Dev Asheesh Chopra on 27/09/24.
//////
////
//////import Foundation
//////
//////struct Conversation: Identifiable, Codable {
//////    var id: UUID
//////    var title: String
//////    var messages: [Message]
//////    var lastUpdated: Date
//////
//////    init(id: UUID = UUID(), title: String = "New Chat", messages: [Message] = [], lastUpdated: Date = Date()) {
//////        self.id = id
//////        self.title = title
//////        self.messages = messages
//////        self.lastUpdated = lastUpdated
//////    }
//////}
////
////
////// Conversation.swift
////import Foundation
////struct Conversation: Identifiable, Codable {
////    var id: String  // Use String
////    var title: String
////    var messages: [Message]
////    var lastUpdated: Date
////
////    init(id: String = "", title: String = "New Chat", messages: [Message] = [], lastUpdated: Date = Date()) {
////        self.id = id
////        self.title = title
////        self.messages = messages
////        self.lastUpdated = lastUpdated
////    }
////}
//
//
//
//

import Foundation

struct Conversation: Identifiable, Codable {
    let id: UUID
    var name: String
    var language: String?   // e.g. "en" or "hi"
    var messages: [ChatMessage]
}
