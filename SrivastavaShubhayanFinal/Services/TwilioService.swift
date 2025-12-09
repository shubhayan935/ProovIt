//
//  TwilioService.swift
//  SrivastavaShubhayanFinal
//
//  Twilio SMS OTP Service
//

import Foundation

final class TwilioService {
    static let shared = TwilioService()

    private let accountSID = ProcessInfo.processInfo.environment["TWILIO_ACCOUNT_SID"] ?? ""
    private let authToken = ProcessInfo.processInfo.environment["TWILIO_AUTH_TOKEN"] ?? ""
    private let twilioPhoneNumber = ProcessInfo.processInfo.environment["TWILIO_PHONE_NUMBER"] ?? ""

    // Dev credentials
    private let devPhoneNumber = "2139104667"
    private let devOTP = "123456"

    // Store OTPs in memory for verification
    private var otpStore: [String: String] = [:]

    private init() {}

    func sendOTP(to phoneNumber: String) async throws -> Bool {
        // Clean phone number (remove formatting)
        let cleaned = phoneNumber.filter { $0.isNumber }

        // Check if dev number
        if cleaned == devPhoneNumber {
            otpStore[cleaned] = devOTP
            return true
        }

        // Generate random 6-digit OTP
        let otp = String(format: "%06d", Int.random(in: 0...999999))
        otpStore[cleaned] = otp

        // Send via Twilio
        guard !accountSID.isEmpty, !authToken.isEmpty, !twilioPhoneNumber.isEmpty else {
            throw NSError(domain: "TwilioService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Twilio credentials not configured"])
        }

        let url = URL(string: "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages.json")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Basic auth
        let loginString = "\(accountSID):\(authToken)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        // Body
        let body = "To=+1\(cleaned)&From=\(twilioPhoneNumber)&Body=Your ProovIt verification code is: \(otp)"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "TwilioService", code: -2,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to send SMS"])
        }

        return true
    }

    func verifyOTP(phoneNumber: String, otp: String) -> Bool {
        let cleaned = phoneNumber.filter { $0.isNumber }
        return otpStore[cleaned] == otp
    }

    func clearOTP(phoneNumber: String) {
        let cleaned = phoneNumber.filter { $0.isNumber }
        otpStore.removeValue(forKey: cleaned)
    }
}
