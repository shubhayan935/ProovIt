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
    private let bucketName = "proof-images"

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
                .from(bucketName)
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

    /// Get a public URL for an uploaded image
    /// - Parameter path: The storage path of the image
    /// - Returns: Public URL to access the image
    func getPublicURL(for path: String) -> URL? {
        do {
            return try client.storage
                .from(bucketName)
                .getPublicURL(path: path)
        } catch {
            
            return nil
        }
    }

    /// Delete an image from storage
    /// - Parameter path: The storage path to delete
    func deleteImage(at path: String) async throws {
        

        do {
            try await client.storage
                .from(bucketName)
                .remove(paths: [path])

            
        } catch {
            
            throw error
        }
    }
}
