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
    var current_count: Int
    var longest_count: Int
    var last_proof_date: Date?
    let created_at: Date?
}
