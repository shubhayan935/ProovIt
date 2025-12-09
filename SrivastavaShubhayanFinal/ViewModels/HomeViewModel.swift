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
            // For now, use a mock UUID
            let mockUserId = UUID()
            goals = try await goalsRepo.fetchGoals(for: mockUserId)
        } catch {
            print("Error loading goals: \(error)")
        }
    }
}
