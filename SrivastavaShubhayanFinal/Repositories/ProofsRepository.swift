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

    // Keep in-memory storage as fallback for dev
    private static var mockProofs: [Proof] = []

    func createProof(goalId: UUID, userId: UUID, imagePath: String, caption: String?) async throws -> Proof {
        do {
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
        } catch {
            print("⚠️ Supabase error, using mock storage: \(error)")
            // Fallback: Create and store in mock
            let newProof = Proof(
                id: UUID(),
                goal_id: goalId,
                user_id: userId,
                image_path: imagePath,
                caption: caption,
                verified: false,
                verification_score: nil,
                created_at: Date()
            )

            Self.mockProofs.append(newProof)
            return newProof
        }
    }

    func getProofs(for goalId: UUID) async throws -> [Proof] {
        do {
            let proofs: [Proof] = try await client
                .from("proofs")
                .select()
                .eq("goal_id", value: goalId.uuidString)
                .order("created_at", ascending: false)
                .execute()
                .value

            return proofs
        } catch {
            print("⚠️ Supabase error, using mock storage: \(error)")
            // Fallback to mock storage
            return Self.mockProofs
                .filter { $0.goal_id == goalId }
        }
    }

    func updateVerification(proofId: UUID, verified: Bool, score: Double) async throws -> Proof {
        do {
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
        } catch {
            print("⚠️ Supabase error, using mock storage: \(error)")
            // Fallback: Update in mock storage
            guard let index = Self.mockProofs.firstIndex(where: { $0.id == proofId }) else {
                throw NSError(domain: "ProofsRepository", code: -1,
                             userInfo: [NSLocalizedDescriptionKey: "Proof not found"])
            }

            let existing = Self.mockProofs[index]
            let updated = Proof(
                id: existing.id,
                goal_id: existing.goal_id,
                user_id: existing.user_id,
                image_path: existing.image_path,
                caption: existing.caption,
                verified: verified,
                verification_score: score,
                created_at: existing.created_at
            )

            Self.mockProofs[index] = updated
            return updated
        }
    }
}
