//
//  OnboardingViewModel.swift
//  SrivastavaShubhayanFinal
//
//  Onboarding View Model
//

import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var fullName = ""
    @Published var username = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var profileCreated = false

    private let profilesRepo: ProfilesRepository

    init(profilesRepo: ProfilesRepository = SupabaseProfilesRepository()) {
        self.profilesRepo = profilesRepo
    }

    var canContinue: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !username.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func createProfile(phoneNumber: String) async {
        guard canContinue else {
            errorMessage = "Please fill in all fields"
            return
        }

        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let trimmedFullName = fullName.trimmingCharacters(in: .whitespaces)
            let trimmedUsername = username.trimmingCharacters(in: .whitespaces)

            _ = try await profilesRepo.createProfile(
                phoneNumber: phoneNumber,
                username: trimmedUsername,
                fullName: trimmedFullName
            )

            profileCreated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
