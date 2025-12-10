//
//  FeedRepository.swift
//  SrivastavaShubhayanFinal
//
//  Repository - Social Feed
//

import Foundation

protocol FeedRepository {
    func getFeed(for userId: UUID) async throws -> [FeedProof]
    func followUser(_ targetUserId: UUID, currentUserId: UUID) async throws -> Bool
    func unfollowUser(_ targetUserId: UUID, currentUserId: UUID) async throws -> Bool
    func getFollowing(for userId: UUID) async throws -> [UUID]
    func getFollowers(for userId: UUID) async throws -> [UUID]
    func getFollowersCount(for userId: UUID) async throws -> Int
    func getFollowingCount(for userId: UUID) async throws -> Int
}

final class SupabaseFeedRepository: FeedRepository {
    private let client = SupabaseClientService.shared.client

    func getFeed(for userId: UUID) async throws -> [FeedProof] {
        // Get list of users current user follows
        let following = try await getFollowing(for: userId)

        // Include current user + followed users
        var userIds = following.map { $0.uuidString }
        userIds.append(userId.uuidString)

        // Fetch proofs from followed users AND current user
        let proofs: [FeedProof] = try await client
            .from("proofs_feed")
            .select()
            .in("user_id", values: userIds)
            .order("created_at", ascending: false)
            .limit(50)
            .execute()
            .value

        return proofs
    }

    func followUser(_ targetUserId: UUID, currentUserId: UUID) async throws -> Bool {
        struct InsertFollowing: Encodable {
            let follower_id: UUID
            let following_id: UUID
        }

        let insert = InsertFollowing(follower_id: currentUserId, following_id: targetUserId)

        try await client
            .from("friendships")
            .insert(insert)
            .execute()

        return true
    }

    func unfollowUser(_ targetUserId: UUID, currentUserId: UUID) async throws -> Bool {
        try await client
            .from("friendships")
            .delete()
            .eq("follower_id", value: currentUserId.uuidString)
            .eq("following_id", value: targetUserId.uuidString)
            .execute()

        return true
    }

    func getFollowing(for userId: UUID) async throws -> [UUID] {
        struct Following: Decodable {
            let following_id: UUID
        }

        let result: [Following] = try await client
            .from("friendships")
            .select("following_id")
            .eq("follower_id", value: userId.uuidString)
            .execute()
            .value

        return result.map { $0.following_id }
    }

    func getFollowers(for userId: UUID) async throws -> [UUID] {
        struct Follower: Decodable {
            let follower_id: UUID
        }

        let result: [Follower] = try await client
            .from("friendships")
            .select("follower_id")
            .eq("following_id", value: userId.uuidString)
            .execute()
            .value

        return result.map { $0.follower_id }
    }

    func getFollowersCount(for userId: UUID) async throws -> Int {
        let followers = try await getFollowers(for: userId)
        return followers.count
    }

    func getFollowingCount(for userId: UUID) async throws -> Int {
        let following = try await getFollowing(for: userId)
        return following.count
    }
}
