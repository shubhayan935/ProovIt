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
        // For now, simulate logged-out state
        // TODO: After adding Supabase SDK, check actual session
        checkSession()
    }

    func checkSession() {
        // TODO: Uncomment after adding Supabase SDK
        /*
        Task {
            do {
                let session = try await SupabaseClientService.shared.client.auth.session
                self.isAuthenticated = (session.user != nil)
                if let user = session.user, let userId = UUID(uuidString: user.id) {
                    self.currentUserId = userId
                }
            } catch {
                self.isAuthenticated = false
                self.currentUserId = nil
            }
        }
        */

        // Temporary: Start with logged-out
        self.isAuthenticated = false
        self.currentUserId = nil
    }

    func loginMock() {
        // For testing without Supabase
        self.isAuthenticated = true
        self.currentUserId = UUID()
    }

    func logout() {
        self.isAuthenticated = false
        self.currentUserId = nil
    }
}
