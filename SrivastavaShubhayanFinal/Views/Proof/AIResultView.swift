//
//  AIResultView.swift
//  SrivastavaShubhayanFinal
//
//  AI Verification Result Screen
//

import SwiftUI

struct VerificationResult {
    let verified: Bool
    let score: Double
    let reason: String
}

struct AIResultView: View {
    let goal: Goal
    let imageData: Data
    let onRetry: () -> Void

    @State private var isLoading = true
    @State private var result: VerificationResult?
    @State private var errorMessage: String?
    @State private var didSaveProof = false
    @State private var isSaving = false
    @State private var uploadedImagePath: String?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.selectedTab) private var selectedTab

    private let imageUploadService = ImageUploadService.shared
    private let aiVerificationService = AIVerificationService.shared
    private let proofsRepo: ProofsRepository = SupabaseProofsRepository()
    private let streaksRepo: StreaksRepository = SupabaseStreaksRepository()

    var body: some View {
        VStack(spacing: 0) {
            // Header with back button and step indicator
            HStack(spacing: AppSpacing.md) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.textDark)
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }

                Spacer()

                StepIndicator(currentStep: 3, totalSteps: 3)

                Spacer()

                // Invisible spacer for centering
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)

            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    // Image preview
                    if let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 8)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.top, AppSpacing.sm)
                    }

                    // Result
                    if isLoading {
                        VStack(spacing: AppSpacing.lg) {
                            ProgressView()
                                .tint(AppColors.primaryGreen)
                                .scaleEffect(1.5)
                                .padding(.top, 40)

                            VStack(spacing: AppSpacing.sm) {
                                Text("Analyzing your proof...")
                                    .font(AppTypography.h2)
                                    .foregroundColor(AppColors.textDark)

                                Text("Do not close the app while we verify your proof, this won't take long.")
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textMedium)
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    } else if let result = result {
                        VStack(spacing: AppSpacing.xl) {
                            // Result card
                            VStack(spacing: AppSpacing.md) {
                                // Title
                                Text(result.verified ? "Great job!" : "Hmm, not quite...")
                                    .font(AppTypography.h2)
                                    .foregroundColor(result.verified ? AppColors.primaryGreen : AppColors.sand)
                                .foregroundColor(AppColors.textMedium)
                                .padding(.horizontal, AppSpacing.lg)

                                // Reason for AI to approve or reject proof
                                Text(result.reason)
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textMedium)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, AppSpacing.lg)
                            }
                            .padding(.vertical, AppSpacing.xl)
                            .frame(maxWidth: .infinity)
                            .background(AppColors.cardWhite)
                            .cornerRadius(24)
                            .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
                            .padding(.horizontal, AppSpacing.lg)
                        }
                    } else if let error = errorMessage {
                        VStack(spacing: AppSpacing.xl) {
                            VStack(spacing: AppSpacing.lg) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.orange)

                                Text("Oops!")
                                    .font(AppTypography.h1)
                                    .foregroundColor(AppColors.textDark)

                                Text(error)
                                    .font(AppTypography.body)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, AppSpacing.xl)
                            .frame(maxWidth: .infinity)
                            .background(AppColors.cardWhite)
                            .cornerRadius(24)
                            .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
                            .padding(.horizontal, AppSpacing.lg)
                        }
                    }
                }
                .padding(.bottom, 120)
            }

            // Bottom button
            if let result = result, result.verified, !didSaveProof {
                VStack(spacing: 0) {

                    Button {
                        saveProof()
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .tint(AppColors.cardWhite)
                            }
                            Text(isSaving ? "Saving..." : "Add to Streak")
                                .font(AppTypography.body.weight(.semibold))
                        }
                        .foregroundColor(AppColors.cardWhite)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.lg)
                        .background(AppColors.primaryGreen)
                        .cornerRadius(20)
                    }
                    .disabled(isSaving)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.lg)
                    .background(AppColors.background)
                }
            } else if let result = result, !result.verified {
                VStack(spacing: 0) {
                    Button {
                        onRetry()
                        dismiss()
                    } label: {
                        Text("Try Another Photo")
                            .font(AppTypography.body.weight(.semibold))
                            .foregroundColor(AppColors.cardWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.lg)
                            .background(AppColors.primaryGreen)
                            .cornerRadius(20)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.lg)
                    .background(AppColors.background)
                }
            } else if errorMessage != nil {
                VStack(spacing: 0) {
                    Button {
                        onRetry()
                        dismiss()
                    } label: {
                        Text("Try Again")
                            .font(AppTypography.body.weight(.semibold))
                            .foregroundColor(AppColors.cardWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.lg)
                            .background(AppColors.primaryGreen)
                            .cornerRadius(20)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.lg)
                    .background(AppColors.background)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            await runVerification()
        }
    }

    private func runVerification() async {
        isLoading = true
        defer { isLoading = false }

        guard let userId = UserSession.shared.userId else {
            errorMessage = "User not logged in"
            return
        }

        do {
            // Step 1: Upload image to Supabase Storage
            
            let imagePath = try await imageUploadService.uploadProofImage(
                imageData: imageData,
                userId: userId,
                goalId: goal.id
            )
            uploadedImagePath = imagePath
            

            // Step 2: Verify with AI
            
            let aiResult = try await aiVerificationService.verifyProof(
                imagePath: imagePath,
                goalTitle: goal.title
            )

            // Convert to VerificationResult
            result = VerificationResult(
                verified: aiResult.verified,
                score: aiResult.score,
                reason: aiResult.reason
            )

            

        } catch {
            print("AI verification failed: \(error.localizedDescription)")
            errorMessage = "Failed to verify proof: \(error.localizedDescription)"

            // Clean up uploaded image if verification failed
            if let imagePath = uploadedImagePath {
                try? await imageUploadService.deleteImage(at: imagePath)
            }
        }
    }

    private func saveProof() {
        guard let userId = UserSession.shared.userId,
              let imagePath = uploadedImagePath,
              let verificationResult = result else {
            errorMessage = "Missing required data to save proof"
            return
        }

        isSaving = true

        Task {
            do {
                // Step 3: Save proof to database with verification results
                let proof = try await proofsRepo.createProof(
                    goalId: goal.id,
                    userId: userId,
                    imagePath: imagePath,
                    caption: nil, // Can add caption input later
                    verified: verificationResult.verified,
                    score: verificationResult.score
                )

                // Step 4: Update streak
                
                let streak = try await streaksRepo.incrementStreak(goalId: goal.id)
                

                isSaving = false

                // Automatically navigate to feed and dismiss
                await MainActor.run {
                    selectedTab.wrappedValue = .social
                    dismiss()
                }

            } catch {
                print("Failed to save proof: \(error.localizedDescription)")
                isSaving = false
                errorMessage = "Failed to save proof: \(error.localizedDescription)"
            }
        }
    }
}
