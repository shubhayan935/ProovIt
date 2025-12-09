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
    // Uncomment after adding Supabase SDK:
    // private let client = SupabaseClientService.shared.client

    func fetchGoals(for userId: UUID) async throws -> [Goal] {
        // TODO: Uncomment after adding Supabase SDK
        /*
        try await client
            .from("goals")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("is_active", value: true)
            .execute()
            .value
        */

        // Temporary mock data:
        return [
            Goal(
                id: UUID(),
                user_id: userId,
                title: "Drink 8 glasses of water",
                description: "Stay hydrated throughout the day",
                frequency: "daily",
                is_active: true,
                created_at: Date()
            ),
            Goal(
                id: UUID(),
                user_id: userId,
                title: "Exercise for 30 minutes",
                description: "Cardio or strength training",
                frequency: "daily",
                is_active: true,
                created_at: Date()
            ),
            Goal(
                id: UUID(),
                user_id: userId,
                title: "Read for 20 minutes",
                description: "Any book or article",
                frequency: "daily",
                is_active: true,
                created_at: Date()
            )
        ]
    }

    func createGoal(
        title: String,
        description: String?,
        frequency: String,
        userId: UUID
    ) async throws -> Goal {
        // TODO: Uncomment after adding Supabase SDK
        /*
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
        */

        // Temporary mock:
        return Goal(
            id: UUID(),
            user_id: userId,
            title: title,
            description: description,
            frequency: frequency,
            is_active: true,
            created_at: Date()
        )
    }
}
