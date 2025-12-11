//
//  ContactsService.swift
//  SrivastavaShubhayanFinal
//
//  Service - Contacts Framework Integration
//  Handles fetching and matching contacts with app users
//

import Foundation
import Contacts

/// Service for accessing device contacts and finding friends
/// Uses Contacts framework to read phone numbers and match with existing users
class ContactsService {
    static let shared = ContactsService()
    private let store = CNContactStore()

    private init() {}

    /// Request permission to access contacts
    /// - Returns: True if permission granted, false otherwise
    func requestAccess() async -> Bool {
        do {
            return try await store.requestAccess(for: .contacts)
        } catch {
            return false
        }
    }

    /// Fetch all contacts with phone numbers
    /// - Returns: Array of contact phone numbers (normalized to digits only)
    func fetchContacts() async throws -> [String] {
        // Check authorization status
        let status = CNContactStore.authorizationStatus(for: .contacts)
        guard status == .authorized else {
            throw ContactsError.notAuthorized
        }

        // Define which contact properties we want to fetch
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor
        ]

        var phoneNumbers: [String] = []
        var totalContactsProcessed = 0
        var contactsWithPhoneNumbers = 0
        var totalPhoneNumbersFound = 0
        var invalidLengthNumbers = 0

        // Fetch all contacts
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)

        try store.enumerateContacts(with: request) { contact, _ in
            totalContactsProcessed += 1

            if !contact.phoneNumbers.isEmpty {
                contactsWithPhoneNumbers += 1
            }

            // Extract phone numbers from contact
            for phoneNumber in contact.phoneNumbers {
                totalPhoneNumbersFound += 1
                let number = phoneNumber.value.stringValue
                // Normalize phone number (remove non-digit characters)
                var normalizedNumber = number.filter { $0.isNumber }

                // Handle US numbers with country code
                // If it starts with "1" and is 11 digits, it's a US number with country code
                if normalizedNumber.count == 11 && normalizedNumber.first == "1" {
                    normalizedNumber = String(normalizedNumber.dropFirst())
                }

                // Only include US numbers (10 digits)
                if normalizedNumber.count == 10 {
                    // Format to match database: +1 323-791-4074
                    let areaCode = normalizedNumber.prefix(3)
                    let firstPart = normalizedNumber.dropFirst(3).prefix(3)
                    let secondPart = normalizedNumber.dropFirst(6)
                    let formattedNumber = "+1 \(areaCode)-\(firstPart)-\(secondPart)"
                    phoneNumbers.append(formattedNumber)
                } else {
                    invalidLengthNumbers += 1
                    if invalidLengthNumbers <= 10 {
                        print("   ⚠️ Skipped number (length \(normalizedNumber.count)): \(number)")
                    }
                }
            }
        }

        // Remove duplicates
        let uniqueNumbers = Array(Set(phoneNumbers))

        print("\n📊 Contacts Fetch Statistics:")
        print("   Total contacts processed: \(totalContactsProcessed)")
        print("   Contacts with phone numbers: \(contactsWithPhoneNumbers)")
        print("   Total phone numbers found: \(totalPhoneNumbersFound)")
        print("   Valid US numbers (10 digits): \(phoneNumbers.count)")
        print("   Invalid length numbers: \(invalidLengthNumbers)")
        print("   Unique US numbers after dedup: \(uniqueNumbers.count)")

        return uniqueNumbers
    }

    /// Check current authorization status
    /// - Returns: True if authorized, false otherwise
    func isAuthorized() -> Bool {
        return CNContactStore.authorizationStatus(for: .contacts) == .authorized
    }
}

enum ContactsError: Error, LocalizedError {
    case notAuthorized
    case fetchFailed

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Contacts access not authorized"
        case .fetchFailed:
            return "Failed to fetch contacts"
        }
    }
}
