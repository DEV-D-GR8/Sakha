//
//  Message.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 27/09/24.
//

//import Foundation

//struct Message: Identifiable, Codable {
//    enum Sender: String, Codable {
//        case user
//        case assistant
//    }
//
//    let id: UUID
//    let text: String
//    let sender: Sender
//    let timestamp: Date
//
//    init(id: UUID = UUID(), text: String, sender: Sender, timestamp: Date = Date()) {
//        self.id = id
//        self.text = text
//        self.sender = sender
//        self.timestamp = timestamp
//    }
//}

// Message.swift

//struct Message: Identifiable, Codable {
//    enum Sender: String, Codable {
//        case user
//        case assistant
//    }
//
//    let id: String  // Changed from UUID to String
//    let text: String
//    let sender: Sender
//    let timestamp: Date
//
//    init(id: String = UUID().uuidString, text: String, sender: Sender, timestamp: Date = Date()) {
//        self.id = id
//        self.text = text
//        self.sender = sender
//        self.timestamp = timestamp
//    }
//}


import Foundation

struct Message: Identifiable, Codable {
    enum Sender: String, Codable {
        case user
        case assistant
    }

    let id: UUID
    let text: String
    let sender: Sender
    let timestamp: Date

    init(id: UUID = UUID(), text: String, sender: Sender, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.sender = sender
        self.timestamp = timestamp
    }
}

