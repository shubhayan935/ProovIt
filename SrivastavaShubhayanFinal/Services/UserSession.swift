//
//  UserSession.swift
//  SrivastavaShubhayanFinal
//
//  User Session Management - Stores current user info with persistence
//

import Foundation

@MainActor
final class UserSession: ObservableObject {
    static let shared = UserSession()

    @Published var currentProfile: Profile? {
        didSet {
            saveToUserDefaults()
        }
    }

    private let userDefaultsKey = "com.proovit.userProfile"

    private init() {
        loadFromUserDefaults()
    }

    var userId: UUID? {
        currentProfile?.id
    }

    var phoneNumber: String? {
        currentProfile?.phone_number
    }

    func setProfile(_ profile: Profile) {
        self.currentProfile = profile
    }

    func clearSession() {
        self.currentProfile = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

    // MARK: - Persistence

    private func saveToUserDefaults() {
        guard let profile = currentProfile else {
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
            return
        }

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(profile)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to save profile to UserDefaults: \(error)")
        }
    }

    private func loadFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let profile = try decoder.decode(Profile.self, from: data)
            self.currentProfile = profile
        } catch {
            print("Failed to load profile from UserDefaults: \(error)")
            // Clear corrupted data
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        }
    }
}
