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

    @State private var isLoading = true
    @State private var result: VerificationResult?
    @State private var errorMessage: String?
    @State private var didSaveProof = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.sageGreen.opacity(0.1)
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.xl) {
                // Image preview
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8)
                }

                // Result
                if isLoading {
                    VStack(spacing: AppSpacing.md) {
                        ProgressView()
                            .tint(AppColors.primaryGreen)
                            .scaleEffect(1.5)

                        Text("Analyzing your proof...")
                            .font(AppTypography.h3)
                            .foregroundColor(AppColors.textDark)

                        Text("Our AI is verifying your photo")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textMedium)
                    }
                } else if let result = result {
                    AppCard {
                        VStack(spacing: AppSpacing.md) {
                            // Icon
                            Image(systemName: result.verified ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(result.verified ? AppColors.primaryGreen : .red)

                            // Title
                            Text(result.verified ? "Great job!" : "Hmm, not quite...")
                                .font(AppTypography.h2)
                                .foregroundColor(result.verified ? AppColors.primaryGreen : .red)

                            // Confidence
                            Text("Confidence: \(Int(result.score * 100))%")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textDark)

                            // Reason
                            Text(result.reason)
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textMedium)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)

                    // Actions
                    VStack(spacing: AppSpacing.md) {
                        if result.verified {
                            if didSaveProof {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Streak updated!")
                                }
                                .font(AppTypography.h3)
                                .foregroundColor(AppColors.primaryGreen)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppColors.primaryGreen.opacity(0.1))
                                .cornerRadius(16)
                            } else {
                                PrimaryButton(title: "Add to Streak") {
                                    saveProof()
                                }
                            }

                            Button("Done") {
                                dismiss()
                            }
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.sand)
                        } else {
                            PrimaryButton(title: "Try Another Photo") {
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                } else if let error = errorMessage {
                    AppCard {
                        VStack(spacing: AppSpacing.md) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.orange)

                            Text("Oops!")
                                .font(AppTypography.h2)
                                .foregroundColor(AppColors.textDark)

                            Text(error)
                                .font(AppTypography.body)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)

                    PrimaryButton(title: "Try Again") {
                        dismiss()
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }

                Spacer()
            }
            .padding(.top, AppSpacing.xl)
        }
        .navigationTitle("Verification Result")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await runVerification()
        }
    }

    private func runVerification() async {
        isLoading = true

        // Simulate API call
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        // Mock result - in real app, this would call the Edge Function
        let verified = Bool.random()
        result = VerificationResult(
            verified: verified,
            score: verified ? 0.85 : 0.45,
            reason: verified
                ? "The image shows clear evidence of completing the goal '\(goal.title)'. Well done!"
                : "I couldn't clearly see evidence of '\(goal.title)' in this image. Try taking a clearer photo that shows the activity."
        )

        isLoading = false
    }

    private func saveProof() {
        // TODO: Save to database and update streak
        // For now, just mark as saved
        didSaveProof = true
    }
}
