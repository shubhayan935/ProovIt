//
//  FeedProof.swift
//  SrivastavaShubhayanFinal
//
//  Data Model - Feed Proof (from proofs_feed view)
//

import Foundation

struct FeedProof: Identifiable, Codable {
    let id: UUID
    let goal_id: UUID
    let user_id: UUID
    let image_path: String
    let caption: String?
    let verified: Bool
    let verification_score: Double?
    let created_at: Date?
    let goal_title: String
    let username: String
}
