//
//  UserSearchViewModel.swift
//  SrivastavaShubhayanFinal
//
//  User Search View Model - Search and follow users
//

import Foundation

@MainActor
final class UserSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [Profile] = []
    @Published var followingIds: Set<UUID> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let profilesRepo: ProfilesRepository
    private let feedRepo: FeedRepository

    init(profilesRepo: ProfilesRepository = SupabaseProfilesRepository(),
         feedRepo: FeedRepository = SupabaseFeedRepository()) {
        self.profilesRepo = profilesRepo
        self.feedRepo = feedRepo
        Task { await loadFollowing() }
    }

    func searchUsers() async {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let results = try await profilesRepo.searchProfiles(query: searchText)

            // Filter out current user
            if let currentUserId = UserSession.shared.userId {
                searchResults = results.filter { $0.id != currentUserId }
            } else {
                searchResults = results
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error searching users: \(error)")
        }
    }

    func loadFollowing() async {
        guard let userId = UserSession.shared.userId else { return }

        do {
            let following = try await feedRepo.getFollowing(for: userId)
            followingIds = Set(following)
        } catch {
            print("Error loading following: \(error)")
        }
    }

    func toggleFollow(user: Profile) async {
        guard let currentUserId = UserSession.shared.userId else { return }

        do {
            if followingIds.contains(user.id) {
                _ = try await feedRepo.unfollowUser(user.id, currentUserId: currentUserId)
                followingIds.remove(user.id)
            } else {
                _ = try await feedRepo.followUser(user.id, currentUserId: currentUserId)
                followingIds.insert(user.id)
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error toggling follow: \(error)")
        }
    }

    func isFollowing(_ userId: UUID) -> Bool {
        followingIds.contains(userId)
    }
}
