//
//  FindFriendsViewModel.swift
//  SrivastavaShubhayanFinal
//
//  ViewModel - Find Friends from Contacts
//  Uses Contacts framework to match device contacts with app users
//

import Foundation

@MainActor
final class FindFriendsViewModel: ObservableObject {
    @Published var contactFriends: [Profile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var permissionDenied = false
    @Published var followingIds: Set<UUID> = []

    private let contactsService = ContactsService.shared
    private let profilesRepo: ProfilesRepository
    private let feedRepo: FeedRepository

    init(profilesRepo: ProfilesRepository = SupabaseProfilesRepository(),
         feedRepo: FeedRepository = SupabaseFeedRepository()) {
        self.profilesRepo = profilesRepo
        self.feedRepo = feedRepo
    }

    /// Request contacts permission and find friends
    func findFriends() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // Check if already authorized
        if !contactsService.isAuthorized() {
            // Request permission
            let granted = await contactsService.requestAccess()
            if !granted {
                permissionDenied = true
                errorMessage = "Contacts access is required to find friends"
                return
            }
        }

        do {
            // Fetch contacts phone numbers
            let phoneNumbers = try await contactsService.fetchContacts()

            // Find users in database with these phone numbers
            let users = try await profilesRepo.findUsersByPhoneNumbers(phoneNumbers)

            // Filter out current user
            guard let currentUserId = UserSession.shared.userId else { return }
            contactFriends = users.filter { $0.id != currentUserId }

            // Load following status for each friend
            await loadFollowingStatus()

        } catch {
            errorMessage = "Failed to find friends: \(error.localizedDescription)"
        }
    }

    /// Load which users are already being followed
    private func loadFollowingStatus() async {
        guard let currentUserId = UserSession.shared.userId else { return }

        do {
            let following = try await feedRepo.getFollowing(for: currentUserId)
            followingIds = Set(following)
        } catch {

        }
    }

    /// Check if user is being followed
    func isFollowing(_ userId: UUID) -> Bool {
        return followingIds.contains(userId)
    }

    /// Toggle follow status for a user
    func toggleFollow(user: Profile) async {
        guard let currentUserId = UserSession.shared.userId else { return }

        do {
            if isFollowing(user.id) {
                _ = try await feedRepo.unfollowUser(user.id, currentUserId: currentUserId)
                followingIds.remove(user.id)
            } else {
                _ = try await feedRepo.followUser(user.id, currentUserId: currentUserId)
                followingIds.insert(user.id)
            }
        } catch {
            errorMessage = "Failed to update follow status"
        }
    }
}
