//
//  Goal.swift
//  SrivastavaShubhayanFinal
//
//  Data Model - Goal
//

import Foundation

struct Goal: Identifiable, Codable {
    let id: UUID
    let user_id: UUID
    let title: String
    let description: String?
    let frequency: String
    let is_active: Bool
    let created_at: Date?
}
