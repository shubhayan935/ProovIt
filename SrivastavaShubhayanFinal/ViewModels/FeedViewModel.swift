//
//  FeedViewModel.swift
//  SrivastavaShubhayanFinal
//
//  Feed View Model
//

import Foundation

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var feedProofs: [FeedProof] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let feedRepo: FeedRepository

    init(feedRepo: FeedRepository = SupabaseFeedRepository()) {
        self.feedRepo = feedRepo
        Task { await loadFeed() }
    }

    func loadFeed() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Get current user ID from session
            guard let userId = UserSession.shared.userId else {
                print("No user logged in")
                feedProofs = []
                return
            }

            feedProofs = try await feedRepo.getFeed(for: userId)
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading feed: \(error)")
        }
    }

    func refresh() async {
        await loadFeed()
    }
}
