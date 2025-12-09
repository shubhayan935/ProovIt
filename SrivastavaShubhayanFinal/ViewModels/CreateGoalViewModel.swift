//
//  CreateGoalViewModel.swift
//  SrivastavaShubhayanFinal
//
//  Create Goal View Model
//

import Foundation

@MainActor
final class CreateGoalViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var selectedFrequency = "daily"
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var goalCreated = false

    let frequencyOptions = [
        "daily",
        "3_per_week",
        "5_per_week",
        "weekly"
    ]

    private let goalsRepo: GoalsRepository

    init(goalsRepo: GoalsRepository = SupabaseGoalsRepository()) {
        self.goalsRepo = goalsRepo
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func frequencyDisplayName(_ frequency: String) -> String {
        switch frequency {
        case "daily": return "Every day"
        case "3_per_week": return "3 times per week"
        case "5_per_week": return "5 times per week"
        case "weekly": return "Once a week"
        default: return frequency
        }
    }

    func createGoal() async {
        guard canSave else {
            errorMessage = "Please enter a goal title"
            return
        }

        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            // Get mock user ID for now
            let mockUserId = UUID()

            let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
            let trimmedDescription = description.trimmingCharacters(in: .whitespaces)

            _ = try await goalsRepo.createGoal(
                title: trimmedTitle,
                description: trimmedDescription.isEmpty ? nil : trimmedDescription,
                frequency: selectedFrequency,
                userId: mockUserId
            )

            goalCreated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
