//
//  AIVerificationService.swift
//  SrivastavaShubhayanFinal
//
//  Service for AI verification of proof images
//

import Foundation

struct AIVerificationResult: Codable {
    let verified: Bool
    let score: Double
    let reason: String
}

final class AIVerificationService {
    static let shared = AIVerificationService()

    private let client = SupabaseClientService.shared.client

    private init() {}

    /// Verify a proof image using the Edge Function
    /// - Parameters:
    ///   - imagePath: Path to the image in Supabase Storage
    ///   - goalTitle: The title of the goal to verify against
    /// - Returns: Verification result with score and reason
    func verifyProof(imagePath: String, goalTitle: String) async throws -> AIVerificationResult {
            
        
        

        do {
            struct VerifyRequest: Encodable {
                let imagePath: String
                let goalTitle: String
            }

            let request = VerifyRequest(imagePath: imagePath, goalTitle: goalTitle)

            let result: AIVerificationResult = try await client.functions
                .invoke(
                    "verify-proof",
                    options: .init(
                        body: request
                    )
                )

            
            
            
            

            return result

        } catch {
            
            throw NSError(
                domain: "AIVerificationService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to verify proof: \(error.localizedDescription)"]
            )
        }
    }
}
