//
//  ProfileViewModel.swift
//  SrivastavaShubhayanFinal
//
//  Profile View Model - Fetches user stats from DB
//

import Foundation
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var totalGoals = 0
    @Published var activeStreaks = 0
    @Published var longestStreak = 0
    @Published var followersCount = 0
    @Published var followingCount = 0
    @Published var profileImageUrl: String?
    @Published var profileImage: UIImage?
    @Published var isLoading = false

    private let goalsRepo: GoalsRepository
    private let feedRepo: FeedRepository
    private let profilesRepo: ProfilesRepository
    private let client = SupabaseClientService.shared.client

    init(goalsRepo: GoalsRepository = SupabaseGoalsRepository(),
         feedRepo: FeedRepository = SupabaseFeedRepository(),
         profilesRepo: ProfilesRepository = SupabaseProfilesRepository()) {
        self.goalsRepo = goalsRepo
        self.feedRepo = feedRepo
        self.profilesRepo = profilesRepo
        Task { await loadStats() }
        Task { await loadProfile() }
    }

    func loadStats() async {
        isLoading = true
        defer { isLoading = false }

        guard let userId = UserSession.shared.userId else {
            
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

            // Get followers and following counts
            followersCount = try await feedRepo.getFollowersCount(for: userId)
            followingCount = try await feedRepo.getFollowingCount(for: userId)

        } catch {
            print("Failed to load profile stats: \(error.localizedDescription)")
        }
    }

    /// Load profile data including profile image
    func loadProfile() async {
        guard let userId = UserSession.shared.userId else { return }

        do {
            // Get profile from database
            guard let phoneNumber = UserSession.shared.currentProfile?.phone_number else { return }
            guard let profile = try await profilesRepo.getProfile(by: phoneNumber) else { return }

            // Update profile image URL
            profileImageUrl = profile.profile_image_url

            // Load profile image if URL exists
            if let imageUrl = profile.profile_image_url {
                await loadProfileImage(path: imageUrl)
            }

        } catch {
            print("Failed to load profile: \(error.localizedDescription)")
        }
    }

    /// Load profile image from storage
    private func loadProfileImage(path: String) async {
        guard let publicURL = ImageUploadService.shared.getProfileImageURL(for: path) else {
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: publicURL)
            if let image = UIImage(data: data) {
                profileImage = image
            }
        } catch {

        }
    }
}
