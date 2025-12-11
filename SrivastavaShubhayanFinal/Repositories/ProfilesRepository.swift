//
//  ProfilesRepository.swift
//  SrivastavaShubhayanFinal
//
//  Repository - Profiles
//

import Foundation

protocol ProfilesRepository {
    func getProfile(by phoneNumber: String) async throws -> Profile?
    func createProfile(phoneNumber: String, username: String, fullName: String) async throws -> Profile
    func updateProfile(id: UUID, username: String?, fullName: String?, profileImageUrl: String?) async throws -> Profile
    func searchProfiles(query: String) async throws -> [Profile]
    func findUsersByPhoneNumbers(_ phoneNumbers: [String]) async throws -> [Profile]
}

final class SupabaseProfilesRepository: ProfilesRepository {
    private let client = SupabaseClientService.shared.client

    func getProfile(by phoneNumber: String) async throws -> Profile? {
        let profiles: [Profile] = try await client
            .from("profiles")
            .select()
            .eq("phone_number", value: phoneNumber)
            .execute()
            .value

        return profiles.first
    }

    func createProfile(phoneNumber: String, username: String, fullName: String) async throws -> Profile {
        struct InsertProfile: Encodable {
            let phone_number: String
            let username: String
            let full_name: String
        }

        let insert = InsertProfile(
            phone_number: phoneNumber,
            username: username,
            full_name: fullName
        )

        let inserted: [Profile] = try await client
            .from("profiles")
            .insert(insert)
            .select()
            .execute()
            .value

        guard let profile = inserted.first else {
            throw NSError(domain: "ProfilesRepository", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "No profile inserted"])
        }
        return profile
    }

    func updateProfile(id: UUID, username: String?, fullName: String?, profileImageUrl: String?) async throws -> Profile {
        struct UpdateProfile: Encodable {
            let username: String?
            let full_name: String?
            let profile_image_url: String?
        }

        let update = UpdateProfile(username: username, full_name: fullName, profile_image_url: profileImageUrl)

        let updated: [Profile] = try await client
            .from("profiles")
            .update(update)
            .eq("id", value: id.uuidString)
            .select()
            .execute()
            .value

        guard let profile = updated.first else {
            throw NSError(domain: "ProfilesRepository", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "No profile updated"])
        }
        return profile
    }

    func findUsersByPhoneNumbers(_ phoneNumbers: [String]) async throws -> [Profile] {
        // Return empty if no phone numbers provided
        print("Finding users for phone numbers: \(phoneNumbers)")
        guard !phoneNumbers.isEmpty else {
            return []
        }

        let all_profiles: [Profile] = try await client
            .from("profiles")
            .select()
            .execute()
            .value

        print("All profiles: \(all_profiles)")

        // Query profiles where phone_number is in the list
        let profiles: [Profile] = try await client
            .from("profiles")
            .select()
            .in("phone_number", values: phoneNumbers)
            .execute()
            .value
        
        print("Matched profiles: \(profiles)")

        return profiles
    }

    func searchProfiles(query: String) async throws -> [Profile] {
        let profiles: [Profile] = try await client
            .from("profiles")
            .select()
            .or("full_name.ilike.%\(query)%,username.ilike.%\(query)%,phone_number.ilike.%\(query)%")
            .limit(20)
            .execute()
            .value

        return profiles
    }
}
