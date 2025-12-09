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
    func updateProfile(id: UUID, username: String?, fullName: String?) async throws -> Profile
}

final class SupabaseProfilesRepository: ProfilesRepository {
    private let client = SupabaseClientService.shared.client

    // Keep in-memory storage as fallback for dev
    private static var mockProfiles: [Profile] = []

    func getProfile(by phoneNumber: String) async throws -> Profile? {
        do {
            let profiles: [Profile] = try await client
                .from("profiles")
                .select()
                .eq("phone_number", value: phoneNumber)
                .execute()
                .value

            return profiles.first
        } catch {
            print("⚠️ Supabase error, using mock storage: \(error)")
            // Fallback to mock storage
            return Self.mockProfiles.first { $0.phone_number == phoneNumber }
        }
    }

    func createProfile(phoneNumber: String, username: String, fullName: String) async throws -> Profile {
        do {
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
        } catch {
            print("⚠️ Supabase error, using mock storage: \(error)")
            // Fallback to mock storage
            let newProfile = Profile(
                id: UUID(),
                phone_number: phoneNumber,
                username: username,
                full_name: fullName,
                created_at: Date()
            )

            Self.mockProfiles.append(newProfile)
            return newProfile
        }
    }

    func updateProfile(id: UUID, username: String?, fullName: String?) async throws -> Profile {
        do {
            struct UpdateProfile: Encodable {
                let username: String?
                let full_name: String?
            }

            let update = UpdateProfile(username: username, full_name: fullName)

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
        } catch {
            print("⚠️ Supabase error, using mock storage: \(error)")
            // Fallback to mock storage
            guard let index = Self.mockProfiles.firstIndex(where: { $0.id == id }) else {
                throw NSError(domain: "ProfilesRepository", code: -1,
                             userInfo: [NSLocalizedDescriptionKey: "Profile not found"])
            }

            let existing = Self.mockProfiles[index]
            let updated = Profile(
                id: existing.id,
                phone_number: existing.phone_number,
                username: username ?? existing.username,
                full_name: fullName ?? existing.full_name,
                created_at: existing.created_at
            )

            Self.mockProfiles[index] = updated
            return updated
        }
    }
}
