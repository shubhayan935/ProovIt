//
//  ImageUploadService.swift
//  SrivastavaShubhayanFinal
//
//  Service for uploading images to Supabase Storage
//

import Foundation
import UIKit

final class ImageUploadService {
    static let shared = ImageUploadService()

    private let client = SupabaseClientService.shared.client
    private let proofBucketName = "proof-images"
    private let profileBucketName = "profile-images"

    private init() {}

    /// Upload an image to Supabase Storage
    /// - Parameters:
    ///   - imageData: The image data to upload
    ///   - userId: The user ID (used for organizing files)
    ///   - goalId: The goal ID (used for organizing files)
    /// - Returns: The path to the uploaded image in storage
    func uploadProofImage(imageData: Data, userId: UUID, goalId: UUID) async throws -> String {
        // Generate unique filename with timestamp
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "\(userId.uuidString)/\(goalId.uuidString)/proof_\(timestamp).jpg"

        

        do {
            // Upload to Supabase Storage
            _ = try await client.storage
                .from(proofBucketName)
                .upload(
                    path: filename,
                    file: imageData,
                    options: .init(
                        contentType: "image/jpeg"
                    )
                )


            return filename

        } catch {

            throw NSError(
                domain: "ImageUploadService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to upload image: \(error.localizedDescription)"]
            )
        }
    }

    /// Upload a profile image to Supabase Storage
    /// - Parameters:
    ///   - imageData: The image data to upload
    ///   - userId: The user ID (used for organizing files)
    /// - Returns: The path to the uploaded image in storage
    func uploadProfileImage(imageData: Data, userId: UUID) async throws -> String {
        // Generate unique filename with timestamp
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "\(userId.uuidString)/profile_\(timestamp).jpg"

        do {
            // Upload to Supabase Storage
            _ = try await client.storage
                .from(profileBucketName)
                .upload(
                    path: filename,
                    file: imageData,
                    options: .init(
                        contentType: "image/jpeg",
                        upsert: true // Overwrite if exists
                    )
                )

            return filename

        } catch {
            throw NSError(
                domain: "ImageUploadService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to upload profile image: \(error.localizedDescription)"]
            )
        }
    }

    /// Get a public URL for an uploaded image
    /// - Parameters:
    ///   - path: The storage path of the image
    ///   - bucket: The bucket name (defaults to proof-images)
    /// - Returns: Public URL to access the image
    func getPublicURL(for path: String, bucket: String? = nil) -> URL? {
        let bucketName = bucket ?? proofBucketName
        do {
            return try client.storage
                .from(bucketName)
                .getPublicURL(path: path)
        } catch {

            return nil
        }
    }

    /// Get public URL for profile image
    /// - Parameter path: The storage path of the profile image
    /// - Returns: Public URL to access the image
    func getProfileImageURL(for path: String) -> URL? {
        return getPublicURL(for: path, bucket: profileBucketName)
    }

    /// Delete an image from storage
    /// - Parameters:
    ///   - path: The storage path to delete
    ///   - bucket: The bucket name (defaults to proof-images)
    func deleteImage(at path: String, bucket: String? = nil) async throws {
        let bucketName = bucket ?? proofBucketName

        do {
            try await client.storage
                .from(bucketName)
                .remove(paths: [path])


        } catch {

            throw error
        }
    }
}
