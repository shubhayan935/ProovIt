//
//  AuthViewModel.swift
//  SrivastavaShubhayanFinal
//
//  Authentication View Model - Phone OTP
//

import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var otp = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var showOTPScreen = false

    private let appVM: AppViewModel
    private let devPhoneNumber = "2139104667"
    private let devOTP = "123"

    init(appVM: AppViewModel) {
        self.appVM = appVM
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

        // Simulate SMS send
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Always succeed for dev number
        if cleaned == devPhoneNumber {
            showOTPScreen = true
        } else {
            // TODO: Integrate with Twilio here
            /*
            // Send OTP via Twilio
            let result = await TwilioService.sendOTP(to: phoneNumber)
            if result.success {
                showOTPScreen = true
            } else {
                errorMessage = "Failed to send SMS. Please try again."
            }
            */

            // For now, just show OTP screen for any number
            showOTPScreen = true
        }
    }

    func verifyOTP() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        guard otp.count == 3 else {
            errorMessage = "Please enter the 3-digit code"
            return
        }

        // Simulate verification
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        let cleaned = phoneNumber.filter { $0.isNumber }

        // Check dev credentials
        if cleaned == devPhoneNumber && otp == devOTP {
            appVM.loginMock()
            return
        }

        // TODO: Verify OTP with Twilio
        /*
        let result = await TwilioService.verifyOTP(phoneNumber: phoneNumber, code: otp)
        if result.success {
            await appVM.checkSession()
        } else {
            errorMessage = "Invalid code. Please try again."
        }
        */

        // For now, accept any 3-digit code
        if otp.count == 3 {
            appVM.loginMock()
        } else {
            errorMessage = "Invalid code. Please try again."
        }
    }

    func backToPhoneEntry() {
        showOTPScreen = false
        otp = ""
        errorMessage = nil
    }
}
