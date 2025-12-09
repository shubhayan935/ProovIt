//
//  Profile.swift
//  SrivastavaShubhayanFinal
//
//  Data Model - Profile
//

import Foundation

struct Profile: Identifiable, Codable {
    let id: UUID
    let phone_number: String
    let username: String?
    let full_name: String?
    let created_at: Date?
}
