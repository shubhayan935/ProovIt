//
//  AuthViewModel.swift
//  SrivastavaShubhayanFinal
//
//  Authentication View Model - Phone OTP with Twilio and Onboarding
//

import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var otp = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var showOTPScreen = false
    @Published var showOnboarding = false

    private let appVM: AppViewModel
    private let twilioService = TwilioService.shared
    private let profilesRepo: ProfilesRepository

    init(appVM: AppViewModel, profilesRepo: ProfilesRepository = SupabaseProfilesRepository()) {
        self.appVM = appVM
        self.profilesRepo = profilesRepo
    }

    var formattedPhoneNumber: String {
        let cleaned = phoneNumber.filter { $0.isNumber }
        guard cleaned.count >= 10 else { return phoneNumber }

        let areaCode = cleaned.prefix(3)
        let prefix = cleaned.dropFirst(3).prefix(3)
        let suffix = cleaned.dropFirst(6).prefix(4)

        return "+1 \(areaCode)-\(prefix)-\(suffix)"
    }

    func sendOTP() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        let cleaned = phoneNumber.filter { $0.isNumber }

        guard cleaned.count == 10 else {
            errorMessage = "Please enter a valid 10-digit phone number"
            return
        }

        do {
            let success = try await twilioService.sendOTP(to: phoneNumber)
            if success {
                showOTPScreen = true
            }
        } catch {
            print("❌ AuthViewModel: Failed to send OTP - \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }

    func verifyOTP() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        guard otp.count == 6 else {
            errorMessage = "Please enter the 6-digit code"
            return
        }

        // Verify OTP with Twilio Verify
        do {
            let isValid = try await twilioService.verifyOTP(phoneNumber: phoneNumber, otp: otp)

            guard isValid else {
                errorMessage = "Invalid verification code"
                return
            }

            // Check if profile exists
            let profile = try await profilesRepo.getProfile(by: formattedPhoneNumber)

            if let existingProfile = profile {
                // Existing user - store profile and authenticate
                UserSession.shared.setProfile(existingProfile)
                appVM.loginMock()
            } else {
                // New user - show onboarding
                showOnboarding = true
            }
        } catch {
            print("❌ AuthViewModel: Failed to verify OTP - \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }

    func completeOnboarding() {
        appVM.loginMock()
    }

    func backToPhoneEntry() {
        showOTPScreen = false
        otp = ""
        errorMessage = nil
    }
}
