//
//  UserProfileViewModel.swift
//  SrivastavaShubhayanFinal
//
//  View Model for viewing other users' profiles
//

import Foundation

@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published var totalGoals = 0
    @Published var activeStreaks = 0
    @Published var longestStreak = 0
    @Published var isFollowing = false
    @Published var isLoading = false

    private let goalsRepo: GoalsRepository
    private let feedRepo: FeedRepository
    private let client = SupabaseClientService.shared.client

    init(goalsRepo: GoalsRepository = SupabaseGoalsRepository(),
         feedRepo: FeedRepository = SupabaseFeedRepository()) {
        self.goalsRepo = goalsRepo
        self.feedRepo = feedRepo
    }

    func loadProfile(userId: UUID) async {
        isLoading = true
        defer { isLoading = false }

        async let goalsTask = loadStats(for: userId)
        async let followingTask = checkFollowing(userId: userId)

        await goalsTask
        await followingTask
    }

    private func loadStats(for userId: UUID) async {
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

    private func checkFollowing(userId: UUID) async {
        guard let currentUserId = UserSession.shared.userId else { return }

        do {
            let following = try await feedRepo.getFollowing(for: currentUserId)
            isFollowing = following.contains(userId)
        } catch {
            print("Error checking following: \(error)")
        }
    }

    func toggleFollow(user: Profile) async {
        guard let currentUserId = UserSession.shared.userId else { return }

        do {
            if isFollowing {
                _ = try await feedRepo.unfollowUser(user.id, currentUserId: currentUserId)
                isFollowing = false
            } else {
                _ = try await feedRepo.followUser(user.id, currentUserId: currentUserId)
                isFollowing = true
            }
        } catch {
            print("Error toggling follow: \(error)")
        }
    }
}
