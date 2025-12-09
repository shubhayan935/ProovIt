//
//  ProfileViewModel.swift
//  SrivastavaShubhayanFinal
//
//  Profile View Model - Fetches user stats from DB
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var totalGoals = 0
    @Published var activeStreaks = 0
    @Published var longestStreak = 0
    @Published var isLoading = false

    private let goalsRepo: GoalsRepository
    private let client = SupabaseClientService.shared.client

    init(goalsRepo: GoalsRepository = SupabaseGoalsRepository()) {
        self.goalsRepo = goalsRepo
        Task { await loadStats() }
    }

    func loadStats() async {
        isLoading = true
        defer { isLoading = false }

        guard let userId = UserSession.shared.userId else {
            print("No user logged in")
            return
        }

        do {
            // Get total goals count
            let goals = try await goalsRepo.fetchGoals(for: userId)
            totalGoals = goals.count

            // Get streaks data from database
            struct StreakData: Decodable {
                let current_count: Int
                let longest_count: Int
            }

            let streaks: [StreakData] = try await client
                .from("streaks")
                .select("current_count, longest_count")
                .in("goal_id", values: goals.map { $0.id.uuidString })
                .execute()
                .value

            // Calculate active streaks (current_count > 0)
            activeStreaks = streaks.filter { $0.current_count > 0 }.count

            // Find longest streak across all goals
            longestStreak = streaks.map { $0.longest_count }.max() ?? 0

        } catch {
            print("Error loading profile stats: \(error)")
        }
    }
}
