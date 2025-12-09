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
}

final class SupabaseFeedRepository: FeedRepository {
    private let client = SupabaseClientService.shared.client

    // Keep mock data as fallback
    private static var mockFollowing: [UUID: Set<UUID>] = [:]
    private static var mockFeedProofs: [FeedProof] = []

    func getFeed(for userId: UUID) async throws -> [FeedProof] {
        do {
            // Get list of users current user follows
            let following = try await getFollowing(for: userId)

            // Fetch proofs from followed users
            let proofs: [FeedProof] = try await client
                .from("proofs_feed")
                .select()
                .in("user_id", values: following.map { $0.uuidString })
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value

            return proofs
        } catch {
            print("⚠️ Supabase error, using mock storage: \(error)")
            // Fallback: Return mock feed
            let following = Self.mockFollowing[userId] ?? []

        // Create some mock feed proofs if empty
        if Self.mockFeedProofs.isEmpty {
            Self.mockFeedProofs = [
                FeedProof(
                    id: UUID(),
                    goal_id: UUID(),
                    user_id: UUID(),
                    image_path: "mock/path1.jpg",
                    caption: "Great morning run! 5k done ✅",
                    verified: true,
                    verification_score: 0.95,
                    created_at: Date().addingTimeInterval(-3600),
                    goal_title: "Morning run",
                    username: "john_doe"
                ),
                FeedProof(
                    id: UUID(),
                    goal_id: UUID(),
                    user_id: UUID(),
                    image_path: "mock/path2.jpg",
                    caption: "Avocado toast and green smoothie",
                    verified: true,
                    verification_score: 0.88,
                    created_at: Date().addingTimeInterval(-7200),
                    goal_title: "Healthy breakfast",
                    username: "jane_smith"
                ),
                FeedProof(
                    id: UUID(),
                    goal_id: UUID(),
                    user_id: UUID(),
                    image_path: "mock/path3.jpg",
                    caption: "15 minutes of mindfulness",
                    verified: true,
                    verification_score: 0.92,
                    created_at: Date().addingTimeInterval(-10800),
                    goal_title: "Meditation session",
                    username: "mike_wilson"
                )
            ]
        }

            return Self.mockFeedProofs
        }
    }

    func followUser(_ targetUserId: UUID, currentUserId: UUID) async throws -> Bool {
        do {
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
        } catch {
            print("⚠️ Supabase error, using mock storage: \(error)")
            // Fallback: Add to mock following
            var following = Self.mockFollowing[currentUserId] ?? []
            following.insert(targetUserId)
            Self.mockFollowing[currentUserId] = following
            return true
        }
    }

    func unfollowUser(_ targetUserId: UUID, currentUserId: UUID) async throws -> Bool {
        do {
            try await client
                .from("friendships")
                .delete()
                .eq("follower_id", value: currentUserId.uuidString)
                .eq("following_id", value: targetUserId.uuidString)
                .execute()

            return true
        } catch {
            print("⚠️ Supabase error, using mock storage: \(error)")
            // Fallback: Remove from mock following
            var following = Self.mockFollowing[currentUserId] ?? []
            following.remove(targetUserId)
            Self.mockFollowing[currentUserId] = following
            return true
        }
    }

    func getFollowing(for userId: UUID) async throws -> [UUID] {
        do {
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
        } catch {
            print("⚠️ Supabase error, using mock storage: \(error)")
            // Fallback: Return mock following
            return Array(Self.mockFollowing[userId] ?? [])
        }
    }
}
