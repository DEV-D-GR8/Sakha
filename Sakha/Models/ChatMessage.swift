//
//  ChatMessage.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 04/02/25.
//

import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: Role
    let text: String
}
