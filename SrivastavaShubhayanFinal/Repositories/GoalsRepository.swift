//
//  GoalsRepository.swift
//  SrivastavaShubhayanFinal
//
//  Repository - Goals
//

import Foundation

protocol GoalsRepository {
    func fetchGoals(for userId: UUID) async throws -> [Goal]
    func createGoal(title: String, description: String?, frequency: String, userId: UUID) async throws -> Goal
}

final class SupabaseGoalsRepository: GoalsRepository {
    private let client = SupabaseClientService.shared.client

    func fetchGoals(for userId: UUID) async throws -> [Goal] {
        let goals: [Goal] = try await client
            .from("goals")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("is_active", value: true)
            .execute()
            .value

        return goals
    }

    func createGoal(
        title: String,
        description: String?,
        frequency: String,
        userId: UUID
    ) async throws -> Goal {
        struct InsertGoal: Encodable {
            let user_id: UUID
            let title: String
            let description: String?
            let frequency: String
        }

        let insert = InsertGoal(user_id: userId, title: title, description: description, frequency: frequency)

        let inserted: [Goal] = try await client
            .from("goals")
            .insert(insert)
            .select()
            .execute()
            .value

        guard let goal = inserted.first else {
            throw NSError(domain: "GoalsRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "No goal inserted"])
        }
        return goal
    }
}
