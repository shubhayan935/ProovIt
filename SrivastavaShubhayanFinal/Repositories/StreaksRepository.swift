//
//  StreaksRepository.swift
//  SrivastavaShubhayanFinal
//
//  Repository - Streaks
//

import Foundation

protocol StreaksRepository {
    func getStreak(for goalId: UUID) async throws -> Streak?
    func createStreak(goalId: UUID) async throws -> Streak
    func incrementStreak(goalId: UUID) async throws -> Streak
}

final class SupabaseStreaksRepository: StreaksRepository {
    private let client = SupabaseClientService.shared.client

    func getStreak(for goalId: UUID) async throws -> Streak? {
        let streaks: [Streak] = try await client
            .from("streaks")
            .select()
            .eq("goal_id", value: goalId.uuidString)
            .execute()
            .value

        return streaks.first
    }

    func createStreak(goalId: UUID) async throws -> Streak {
        struct InsertStreak: Encodable {
            let goal_id: UUID
            let current_count: Int = 0
            let longest_count: Int = 0
        }

        let insert = InsertStreak(goal_id: goalId)

        let inserted: [Streak] = try await client
            .from("streaks")
            .insert(insert)
            .select()
            .execute()
            .value

        guard let streak = inserted.first else {
            throw NSError(domain: "StreaksRepository", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "No streak created"])
        }
        return streak
    }

    func incrementStreak(goalId: UUID) async throws -> Streak {
        // Get current streak or create if doesn't exist
        var streak = try await getStreak(for: goalId)

        if streak == nil {
            streak = try await createStreak(goalId: goalId)
        }

        guard var currentStreak = streak else {
            throw NSError(domain: "StreaksRepository", code: -2,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to get streak"])
        }

        let today = Date()
        let calendar = Calendar.current

        // Check if last proof was yesterday (continues streak) or earlier (resets)
        if let lastProofDate = currentStreak.last_proof_date {
            let daysSinceLastProof = calendar.dateComponents([.day], from: lastProofDate, to: today).day ?? 0

            if daysSinceLastProof == 1 {
                // Continue streak
                currentStreak.current_count += 1
            } else if daysSinceLastProof > 1 {
                // Reset streak
                currentStreak.current_count = 1
            }
            // If daysSinceLastProof == 0, it's the same day, don't increment (already submitted today)
        } else {
            // First proof
            currentStreak.current_count = 1
        }

        // Update longest streak if current is higher
        if currentStreak.current_count > currentStreak.longest_count {
            currentStreak.longest_count = currentStreak.current_count
        }

        // Update in database
        struct UpdateStreak: Encodable {
            let current_count: Int
            let longest_count: Int
            let last_proof_date: String
        }

        let dateFormatter = ISO8601DateFormatter()
        let update = UpdateStreak(
            current_count: currentStreak.current_count,
            longest_count: currentStreak.longest_count,
            last_proof_date: dateFormatter.string(from: today)
        )

        let updated: [Streak] = try await client
            .from("streaks")
            .update(update)
            .eq("goal_id", value: goalId.uuidString)
            .select()
            .execute()
            .value

        guard let updatedStreak = updated.first else {
            throw NSError(domain: "StreaksRepository", code: -3,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to update streak"])
        }

        return updatedStreak
    }
}
