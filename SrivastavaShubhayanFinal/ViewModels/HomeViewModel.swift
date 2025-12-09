//
//  HomeViewModel.swift
//  SrivastavaShubhayanFinal
//
//  Home Screen View Model
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var isLoading = false

    private let goalsRepo: GoalsRepository

    init(goalsRepo: GoalsRepository = SupabaseGoalsRepository()) {
        self.goalsRepo = goalsRepo
        Task { await loadGoals() }
    }

    func loadGoals() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Get current user ID from session
            guard let userId = UserSession.shared.userId else {
                print("No user logged in")
                goals = []
                return
            }

            goals = try await goalsRepo.fetchGoals(for: userId)
        } catch {
            print("Error loading goals: \(error)")
        }
    }
}
