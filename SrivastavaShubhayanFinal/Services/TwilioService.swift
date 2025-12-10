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
        
        
        
        
    }

    func sendOTP(to phoneNumber: String) async throws -> Bool {
        // Clean phone number (remove formatting and whitespace)
        
        let cleaned = phoneNumber.filter { $0.isNumber }.trimmingCharacters(in: .whitespacesAndNewlines)
        

        // Check if dev number
        if cleaned == devPhoneNumber {
            
            return true
        }

        // Validate credentials
        guard !accountSID.isEmpty, !authToken.isEmpty, !verifyServiceSID.isEmpty else {
            
            
            
            
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
            
            throw NSError(domain: "TwilioService", code: -3,
                         userInfo: [NSLocalizedDescriptionKey: "Phone number must be 10 digits"])
        }

        let formattedNumber = "+1\(cleaned)"
        

        // Manually build URL encoded body
        // We can't use URLComponents because it doesn't properly encode + for form data
        var allowedCharacters = CharacterSet.alphanumerics
        let encodedNumber = formattedNumber.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? formattedNumber
        

        let bodyString = "To=\(encodedNumber)&Channel=sms"
        

        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                
                throw NSError(domain: "TwilioService", code: -2,
                             userInfo: [NSLocalizedDescriptionKey: "Invalid response from Twilio Verify"])
            }

            

            if !(200...299).contains(httpResponse.statusCode) {
                // Try to parse error response
                if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
                    if let message = errorResponse["message"] as? String {
                        throw NSError(domain: "TwilioService", code: httpResponse.statusCode,
                                     userInfo: [NSLocalizedDescriptionKey: "Twilio error: \(message)"])
                    }
                }
                throw NSError(domain: "TwilioService", code: httpResponse.statusCode,
                             userInfo: [NSLocalizedDescriptionKey: "Failed to send verification (Status: \(httpResponse.statusCode))"])
            }

            
            return true

        } catch let error as NSError {
            
            
            
            if let userInfo = error.userInfo as? [String: Any] {
                
            }
            throw error
        }
    }

    func verifyOTP(phoneNumber: String, otp: String) async throws -> Bool {
        let cleaned = phoneNumber.filter { $0.isNumber }.trimmingCharacters(in: .whitespacesAndNewlines)

        

        // Check if dev number
        if cleaned == devPhoneNumber {
            
            return otp == devOTP
        }

        // Validate credentials
        guard !accountSID.isEmpty, !authToken.isEmpty, !verifyServiceSID.isEmpty else {
            
            throw NSError(domain: "TwilioService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Twilio Verify credentials not configured"])
        }

        // Ensure phone number has exactly 10 digits
        guard cleaned.count == 10 else {
            
            throw NSError(domain: "TwilioService", code: -3,
                         userInfo: [NSLocalizedDescriptionKey: "Phone number must be 10 digits"])
        }

        let formattedNumber = "+1\(cleaned)"
        

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
        

        let bodyString = "To=\(encodedNumber)&Code=\(otp)"
        

        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                
                throw NSError(domain: "TwilioService", code: -2,
                             userInfo: [NSLocalizedDescriptionKey: "Invalid response from Twilio Verify"])
            }

            

            if !(200...299).contains(httpResponse.statusCode) {
                if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
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
                
                let isApproved = status == "approved"
                if isApproved {
                    
                } else {
                    
                }
                return isApproved
            }

            return false

        } catch let error as NSError {
            
            throw error
        }
    }
}
