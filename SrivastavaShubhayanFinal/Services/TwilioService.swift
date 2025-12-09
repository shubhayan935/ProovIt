//
//  TwilioService.swift
//  SrivastavaShubhayanFinal
//
//  Twilio Verify OTP Service
//

import Foundation

final class TwilioService {
    static let shared = TwilioService()

    private let accountSID = ProcessInfo.processInfo.environment["TWILIO_ACCOUNT_SID"] ?? ""
    private let authToken = ProcessInfo.processInfo.environment["TWILIO_AUTH_TOKEN"] ?? ""
    private let verifyServiceSID = ProcessInfo.processInfo.environment["TWILIO_VERIFY_SERVICE_SID"] ?? ""

    // Dev credentials
    private let devPhoneNumber = "2139104667"
    private let devOTP = "123456"

    private init() {
        // Debug: Print environment variables (masked for security)
        print("🔐 Twilio Verify Configuration:")
        print("   - Account SID: \(accountSID.isEmpty ? "NOT SET" : "\(accountSID.prefix(4))...\(accountSID.suffix(4))")")
        print("   - Auth Token: \(authToken.isEmpty ? "NOT SET" : "****")")
        print("   - Verify Service SID: \(verifyServiceSID.isEmpty ? "NOT SET" : "\(verifyServiceSID.prefix(4))...\(verifyServiceSID.suffix(4))")")
    }

    func sendOTP(to phoneNumber: String) async throws -> Bool {
        // Clean phone number (remove formatting and whitespace)
        print("📥 Raw phone number input: '\(phoneNumber)'")
        let cleaned = phoneNumber.filter { $0.isNumber }.trimmingCharacters(in: .whitespacesAndNewlines)
        print("🧹 Cleaned phone number: '\(cleaned)' (length: \(cleaned.count))")

        // Check if dev number
        if cleaned == devPhoneNumber {
            print("✅ Dev number detected, bypassing Twilio Verify")
            return true
        }

        // Validate credentials
        guard !accountSID.isEmpty, !authToken.isEmpty, !verifyServiceSID.isEmpty else {
            print("❌ Twilio Verify credentials not configured")
            print("   - Account SID: \(accountSID.isEmpty ? "MISSING" : "present")")
            print("   - Auth Token: \(authToken.isEmpty ? "MISSING" : "present")")
            print("   - Verify Service SID: \(verifyServiceSID.isEmpty ? "MISSING" : "present")")
            throw NSError(domain: "TwilioService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Twilio Verify credentials not configured. Please check your environment variables."])
        }

        // Send verification via Twilio Verify API
        let url = URL(string: "https://verify.twilio.com/v2/Services/\(verifyServiceSID)/Verifications")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Basic auth
        let loginString = "\(accountSID):\(authToken)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        // Body - send OTP via SMS
        // Ensure phone number has exactly 10 digits
        guard cleaned.count == 10 else {
            print("❌ Invalid phone number length: \(cleaned.count) digits")
            throw NSError(domain: "TwilioService", code: -3,
                         userInfo: [NSLocalizedDescriptionKey: "Phone number must be 10 digits"])
        }

        let formattedNumber = "+1\(cleaned)"
        print("📞 Formatted number: \(formattedNumber)")

        // Manually build URL encoded body
        // We can't use URLComponents because it doesn't properly encode + for form data
        var allowedCharacters = CharacterSet.alphanumerics
        let encodedNumber = formattedNumber.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? formattedNumber
        print("🔐 Encoded number: \(encodedNumber)")

        let bodyString = "To=\(encodedNumber)&Channel=sms"
        print("📦 Request body: \(bodyString)")

        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        print("🔄 Sending verification request to Twilio Verify API...")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response from Twilio Verify")
                throw NSError(domain: "TwilioService", code: -2,
                             userInfo: [NSLocalizedDescriptionKey: "Invalid response from Twilio Verify"])
            }

            print("📡 Twilio Verify API response status: \(httpResponse.statusCode)")

            if !(200...299).contains(httpResponse.statusCode) {
                // Try to parse error response
                if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("❌ Twilio Verify error response: \(errorResponse)")
                    if let message = errorResponse["message"] as? String {
                        throw NSError(domain: "TwilioService", code: httpResponse.statusCode,
                                     userInfo: [NSLocalizedDescriptionKey: "Twilio error: \(message)"])
                    }
                }
                throw NSError(domain: "TwilioService", code: httpResponse.statusCode,
                             userInfo: [NSLocalizedDescriptionKey: "Failed to send verification (Status: \(httpResponse.statusCode))"])
            }

            print("✅ Verification sent successfully")
            return true

        } catch let error as NSError {
            print("❌ Error sending verification: \(error.localizedDescription)")
            print("   Domain: \(error.domain)")
            print("   Code: \(error.code)")
            if let userInfo = error.userInfo as? [String: Any] {
                print("   UserInfo: \(userInfo)")
            }
            throw error
        }
    }

    func verifyOTP(phoneNumber: String, otp: String) async throws -> Bool {
        let cleaned = phoneNumber.filter { $0.isNumber }.trimmingCharacters(in: .whitespacesAndNewlines)

        print("🔍 Attempting to verify OTP for: \(cleaned)")

        // Check if dev number
        if cleaned == devPhoneNumber {
            print("✅ Dev number detected, checking against dev OTP")
            return otp == devOTP
        }

        // Validate credentials
        guard !accountSID.isEmpty, !authToken.isEmpty, !verifyServiceSID.isEmpty else {
            print("❌ Twilio Verify credentials not configured")
            throw NSError(domain: "TwilioService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Twilio Verify credentials not configured"])
        }

        // Ensure phone number has exactly 10 digits
        guard cleaned.count == 10 else {
            print("❌ Invalid phone number length: \(cleaned.count) digits")
            throw NSError(domain: "TwilioService", code: -3,
                         userInfo: [NSLocalizedDescriptionKey: "Phone number must be 10 digits"])
        }

        let formattedNumber = "+1\(cleaned)"
        print("📞 Formatted number: \(formattedNumber)")

        // Verify OTP via Twilio Verify API
        let url = URL(string: "https://verify.twilio.com/v2/Services/\(verifyServiceSID)/VerificationCheck")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Basic auth
        let loginString = "\(accountSID):\(authToken)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        // Manually build URL encoded body
        var allowedCharacters = CharacterSet.alphanumerics
        let encodedNumber = formattedNumber.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? formattedNumber
        print("🔐 Encoded number: \(encodedNumber)")

        let bodyString = "To=\(encodedNumber)&Code=\(otp)"
        print("📦 Request body: \(bodyString)")

        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        print("🔄 Sending verification check to Twilio Verify API...")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response from Twilio Verify")
                throw NSError(domain: "TwilioService", code: -2,
                             userInfo: [NSLocalizedDescriptionKey: "Invalid response from Twilio Verify"])
            }

            print("📡 Twilio Verify check response status: \(httpResponse.statusCode)")

            if !(200...299).contains(httpResponse.statusCode) {
                if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("❌ Twilio Verify error response: \(errorResponse)")
                    if let message = errorResponse["message"] as? String {
                        throw NSError(domain: "TwilioService", code: httpResponse.statusCode,
                                     userInfo: [NSLocalizedDescriptionKey: "Twilio error: \(message)"])
                    }
                }
                return false
            }

            // Parse response to check status
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = jsonResponse["status"] as? String {
                print("📋 Verification status: \(status)")
                let isApproved = status == "approved"
                if isApproved {
                    print("✅ OTP verified successfully")
                } else {
                    print("❌ OTP verification failed - status: \(status)")
                }
                return isApproved
            }

            return false

        } catch let error as NSError {
            print("❌ Error verifying OTP: \(error.localizedDescription)")
            throw error
        }
    }
}
