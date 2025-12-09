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

    // Keep in-memory storage as fallback for dev
    private static var mockGoals: [Goal] = [
        Goal(
            id: UUID(),
            user_id: UUID(),
            title: "Drink 8 glasses of water",
            description: "Stay hydrated throughout the day",
            frequency: "daily",
            is_active: true,
            created_at: Date()
        ),
        Goal(
            id: UUID(),
            user_id: UUID(),
            title: "Exercise for 30 minutes",
            description: "Cardio or strength training",
            frequency: "daily",
            is_active: true,
            created_at: Date()
        ),
        Goal(
            id: UUID(),
            user_id: UUID(),
            title: "Read for 20 minutes",
            description: "Any book or article",
            frequency: "daily",
            is_active: true,
            created_at: Date()
        )
    ]

    func fetchGoals(for userId: UUID) async throws -> [Goal] {
        do {
            let goals: [Goal] = try await client
                .from("goals")
                .select()
                .eq("user_id", value: userId.uuidString)
                .eq("is_active", value: true)
                .execute()
                .value

            return goals
        } catch {
            print("⚠️ Supabase error, using mock storage: \(error)")
            // Fallback to mock storage
            return Self.mockGoals.filter { $0.is_active }
        }
    }

    func createGoal(
        title: String,
        description: String?,
        frequency: String,
        userId: UUID
    ) async throws -> Goal {
        do {
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
        } catch {
            print("⚠️ Supabase error, using mock storage: \(error)")
            // Fallback: Create and store new goal
            let newGoal = Goal(
                id: UUID(),
                user_id: userId,
                title: title,
                description: description,
                frequency: frequency,
                is_active: true,
                created_at: Date()
            )

            Self.mockGoals.append(newGoal)
            return newGoal
        }
    }
}
