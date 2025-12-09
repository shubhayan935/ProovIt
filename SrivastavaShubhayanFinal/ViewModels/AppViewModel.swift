//
//  AppViewModel.swift
//  SrivastavaShubhayanFinal
//
//  Main App State Management
//

import Foundation

@MainActor
final class AppViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUserId: UUID?

    init() {
        checkSession()
    }

    func checkSession() {
        // Check if user has a saved session in UserDefaults
        if let profile = UserSession.shared.currentProfile {
            self.isAuthenticated = true
            self.currentUserId = profile.id
            print("✅ Restored session for user: \(profile.phone_number)")
        } else {
            self.isAuthenticated = false
            self.currentUserId = nil
        }
    }

    func loginMock() {
        // Use real user ID from session
        self.isAuthenticated = true
        self.currentUserId = UserSession.shared.userId
    }

    func logout() {
        self.isAuthenticated = false
        self.currentUserId = nil
        UserSession.shared.clearSession()
    }
}
