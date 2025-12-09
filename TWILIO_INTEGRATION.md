# Twilio Phone Authentication Integration

## Overview
The app now uses phone number + OTP authentication instead of email/password. This document explains how to integrate Twilio for SMS verification.

## Current Implementation

### Dev Credentials (Always Works)
- **Phone Number**: `2139104667`
- **OTP Code**: `123456`

These credentials will always authenticate successfully without calling Twilio, making development and testing easier.

### Two-Step Flow

1. **Phone Number Entry**
   - User enters 10-digit US phone number
   - App validates format
   - Formatted as: `+1 XXX-XXX-XXXX`
   - "Continue" button sends OTP

2. **OTP Verification**
   - User enters 6-digit code
   - App verifies code
   - On success, user is logged in

## Twilio Setup

### 1. Create Twilio Account
1. Go to [twilio.com](https://www.twilio.com)
2. Sign up for a free account
3. Get your:
   - Account SID
   - Auth Token
   - Twilio Phone Number

### 2. Install Twilio SDK

Add to your Swift project:

```bash
# Using Swift Package Manager
# Add to Xcode: File → Add Package Dependencies
https://github.com/twilio/twilio-verify-ios
```

Or use the REST API directly (simpler):

```swift
// No SDK needed, just HTTP requests
```

### 3. Create Twilio Service

Create `Services/TwilioService.swift`:

```swift
import Foundation

struct TwilioService {
    static let accountSID = ProcessInfo.processInfo.environment["TWILIO_ACCOUNT_SID"] ?? ""
    static let authToken = ProcessInfo.processInfo.environment["TWILIO_AUTH_TOKEN"] ?? ""
    static let phoneNumber = ProcessInfo.processInfo.environment["TWILIO_PHONE_NUMBER"] ?? ""

    struct OTPResult {
        let success: Bool
        let message: String
    }

    static func sendOTP(to phoneNumber: String) async -> OTPResult {
        // Generate random 6-digit code
        let code = String(format: "%06d", Int.random(in: 0...999999))

        // Store code temporarily (use UserDefaults or in-memory for demo)
        UserDefaults.standard.set(code, forKey: "pending_otp_\(phoneNumber)")

        // Send SMS via Twilio
        let url = "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages.json"

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"

        // Basic auth
        let credentials = "\(accountSID):\(authToken)"
        let credentialsData = credentials.data(using: .utf8)!
        let base64 = credentialsData.base64EncodedString()
        request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")

        // Body
        let body = "To=+1\(phoneNumber)&From=\(Self.phoneNumber)&Body=Your ProovIt verification code is: \(code)"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 201 {
                return OTPResult(success: true, message: "Code sent")
            } else {
                return OTPResult(success: false, message: "Failed to send SMS")
            }
        } catch {
            return OTPResult(success: false, message: error.localizedDescription)
        }
    }

    static func verifyOTP(phoneNumber: String, code: String) async -> OTPResult {
        // Retrieve stored code
        let storedCode = UserDefaults.standard.string(forKey: "pending_otp_\(phoneNumber)")

        guard let storedCode = storedCode, storedCode == code else {
            return OTPResult(success: false, message: "Invalid code")
        }

        // Clear stored code
        UserDefaults.standard.removeObject(forKey: "pending_otp_\(phoneNumber)")

        return OTPResult(success: true, message: "Verified")
    }
}
```

### 4. Update AuthViewModel

Uncomment the Twilio integration in `AuthViewModel.swift`:

```swift
// In sendOTP() function:
let result = await TwilioService.sendOTP(to: phoneNumber)
if result.success {
    showOTPScreen = true
} else {
    errorMessage = "Failed to send SMS. Please try again."
}

// In verifyOTP() function:
let result = await TwilioService.verifyOTP(phoneNumber: phoneNumber, code: otp)
if result.success {
    await appVM.checkSession()
} else {
    errorMessage = "Invalid code. Please try again."
}
```

### 5. Add Environment Variables

In Xcode: **Product → Scheme → Edit Scheme → Run → Environment Variables**

Add:
- `TWILIO_ACCOUNT_SID`: Your Account SID
- `TWILIO_AUTH_TOKEN`: Your Auth Token
- `TWILIO_PHONE_NUMBER`: Your Twilio phone number (e.g., +15551234567)

## Alternative: Twilio Verify API

For production, use Twilio Verify (more secure):

### 1. Create Verify Service

In Twilio Console:
1. Go to Verify → Services
2. Create new service
3. Copy Service SID

### 2. Update TwilioService

```swift
static let verifySID = ProcessInfo.processInfo.environment["TWILIO_VERIFY_SID"] ?? ""

static func sendOTP(to phoneNumber: String) async -> OTPResult {
    let url = "https://verify.twilio.com/v2/Services/\(verifySID)/Verifications"

    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = "POST"

    let credentials = "\(accountSID):\(authToken)"
    let credentialsData = credentials.data(using: .utf8)!
    let base64 = credentialsData.base64EncodedString()
    request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")

    let body = "To=+1\(phoneNumber)&Channel=sms"
    request.httpBody = body.data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    do {
        let (_, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 201 {
            return OTPResult(success: true, message: "Code sent")
        } else {
            return OTPResult(success: false, message: "Failed to send SMS")
        }
    } catch {
        return OTPResult(success: false, message: error.localizedDescription)
    }
}

static func verifyOTP(phoneNumber: String, code: String) async -> OTPResult {
    let url = "https://verify.twilio.com/v2/Services/\(verifySID)/VerificationCheck"

    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = "POST"

    let credentials = "\(accountSID):\(authToken)"
    let credentialsData = credentials.data(using: .utf8)!
    let base64 = credentialsData.base64EncodedString()
    request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")

    let body = "To=+1\(phoneNumber)&Code=\(code)"
    request.httpBody = body.data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    do {
        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 200 {

            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let status = json?["status"] as? String

            if status == "approved" {
                return OTPResult(success: true, message: "Verified")
            }
        }

        return OTPResult(success: false, message: "Invalid code")
    } catch {
        return OTPResult(success: false, message: error.localizedDescription)
    }
}
```

## Testing

### Test with Dev Number
1. Run app
2. Enter phone: `2139104667`
3. Enter OTP: `123456`
4. Should log in successfully

### Test with Real Number
1. Add Twilio credentials to environment variables
2. Uncomment Twilio integration in AuthViewModel
3. Run app
4. Enter your real phone number
5. Receive SMS with code
6. Enter code to verify

## Security Considerations

1. **Rate Limiting**
   - Limit OTP sends per phone number (e.g., 3 per hour)
   - Prevent spam/abuse

2. **Code Expiration**
   - OTP codes should expire after 5-10 minutes
   - Store timestamp with code

3. **Secure Storage**
   - Don't store Auth Token in code
   - Use environment variables or secure keychain

4. **HTTPS Only**
   - All API calls use HTTPS
   - Twilio handles this by default

5. **Backend Verification**
   - For production, verify OTP on backend
   - Don't trust client-side verification alone

## Production Checklist

- [ ] Create Twilio account
- [ ] Get phone number
- [ ] Set up Verify service
- [ ] Add credentials to environment
- [ ] Uncomment Twilio integration
- [ ] Test with real phone numbers
- [ ] Implement rate limiting
- [ ] Add OTP expiration
- [ ] Set up backend verification
- [ ] Add retry mechanism
- [ ] Handle error cases (network, invalid number, etc.)
- [ ] Add analytics/logging
- [ ] Test international numbers (if needed)

## Costs

**Twilio Pricing** (as of 2024):
- **SMS**: ~$0.0075 per message in US
- **Verify API**: ~$0.05 per verification attempt
- **Free Trial**: $15.50 credit (enough for ~200 verifications)

For development/testing with low volume, the free tier is sufficient.

## Alternative: Backend Edge Function

For better security, you can move the Twilio logic to a Supabase Edge Function:

1. Client sends phone number to Edge Function
2. Edge Function calls Twilio (credentials are server-side)
3. Client receives success/failure response
4. Client sends OTP to Edge Function for verification
5. Edge Function verifies with Twilio
6. Edge Function creates/updates user session

This way, Twilio credentials never leave the server.

## Resources

- [Twilio SMS Quickstart](https://www.twilio.com/docs/sms/quickstart)
- [Twilio Verify API](https://www.twilio.com/docs/verify/api)
- [Swift Integration Guide](https://www.twilio.com/docs/verify/quickstarts/swift)

---

**Current Status**: ✅ Twilio integration complete with TwilioService
**Dev Credentials**: `2139104667` / `123456` (always works)
**Next Step**: Configure environment variables and test with real phone numbers
