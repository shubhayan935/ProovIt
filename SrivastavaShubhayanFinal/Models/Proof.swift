//
//  Proof.swift
//  SrivastavaShubhayanFinal
//
//  Data Model - Proof
//

import Foundation

struct Proof: Identifiable, Codable {
    let id: UUID
    let goal_id: UUID
    let user_id: UUID
    let image_path: String
    let caption: String?
    let verified: Bool
    let verification_score: Double?
    let created_at: Date?
}
