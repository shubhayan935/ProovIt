//
//  AuthViewModel.swift
//  SrivastavaShubhayanFinal
//
//  Authentication View Model
//

import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let appVM: AppViewModel

    init(appVM: AppViewModel) {
        self.appVM = appVM
    }

    func login() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        // TODO: Uncomment after adding Supabase SDK
        /*
        do {
            _ = try await SupabaseClientService.shared.client.auth.signIn(email: email, password: password)
            await appVM.checkSession()
        } catch {
            errorMessage = error.localizedDescription
        }
        */

        // Temporary mock login
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        appVM.loginMock()
    }

    func signUp() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        // TODO: Uncomment after adding Supabase SDK
        /*
        do {
            _ = try await SupabaseClientService.shared.client.auth.signUp(email: email, password: password)
            await appVM.checkSession()
        } catch {
            errorMessage = error.localizedDescription
        }
        */

        // Temporary mock signup
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        appVM.loginMock()
    }
}
