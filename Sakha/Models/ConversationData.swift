//
//  ConversationsData.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 24/10/24.
//

import Foundation

struct ConversationData: Codable {
    let conversation_id: String
    let messages: [Message]
}
