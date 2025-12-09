//
//  ProofsRepository.swift
//  SrivastavaShubhayanFinal
//
//  Repository - Proofs
//

import Foundation

protocol ProofsRepository {
    func createProof(goalId: UUID, userId: UUID, imagePath: String, caption: String?) async throws -> Proof
    func getProofs(for goalId: UUID) async throws -> [Proof]
    func updateVerification(proofId: UUID, verified: Bool, score: Double) async throws -> Proof
}

final class SupabaseProofsRepository: ProofsRepository {
    private let client = SupabaseClientService.shared.client

    func createProof(goalId: UUID, userId: UUID, imagePath: String, caption: String?) async throws -> Proof {
        struct InsertProof: Encodable {
            let goal_id: UUID
            let user_id: UUID
            let image_path: String
            let caption: String?
        }

        let insert = InsertProof(
            goal_id: goalId,
            user_id: userId,
            image_path: imagePath,
            caption: caption
        )

        let inserted: [Proof] = try await client
            .from("proofs")
            .insert(insert)
            .select()
            .execute()
            .value

        guard let proof = inserted.first else {
            throw NSError(domain: "ProofsRepository", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "No proof inserted"])
        }
        return proof
    }

    func getProofs(for goalId: UUID) async throws -> [Proof] {
        let proofs: [Proof] = try await client
            .from("proofs")
            .select()
            .eq("goal_id", value: goalId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value

        return proofs
    }

    func updateVerification(proofId: UUID, verified: Bool, score: Double) async throws -> Proof {
        struct UpdateVerification: Encodable {
            let verified: Bool
            let verification_score: Double
        }

        let update = UpdateVerification(verified: verified, verification_score: score)

        let updated: [Proof] = try await client
            .from("proofs")
            .update(update)
            .eq("id", value: proofId.uuidString)
            .select()
            .execute()
            .value

        guard let proof = updated.first else {
            throw NSError(domain: "ProofsRepository", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "No proof updated"])
        }
        return proof
    }
}
