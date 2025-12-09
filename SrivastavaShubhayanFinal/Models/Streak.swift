//
//  Streak.swift
//  SrivastavaShubhayanFinal
//
//  Data Model - Streak
//

import Foundation

struct Streak: Identifiable, Codable {
    let id: UUID
    let goal_id: UUID
    let current_count: Int
    let longest_count: Int
    let last_proof_date: Date?
    let created_at: Date?
}
