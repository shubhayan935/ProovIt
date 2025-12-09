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
        VStack(spacing: 0) {
            // Header with back button and step indicator
            HStack(spacing: AppSpacing.md) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.textDark)
                        .frame(width: 44, height: 44)
                        .background(AppColors.cardWhite)
                        .clipShape(Circle())
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

                                Text("Our AI is verifying your photo")
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textMedium)
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    } else if let result = result {
                        VStack(spacing: AppSpacing.xl) {
                            // Result card
                            VStack(spacing: AppSpacing.lg) {
                                // Icon
                                Image(systemName: result.verified ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(result.verified ? AppColors.primaryGreen : .red)

                                // Title
                                Text(result.verified ? "Great job!" : "Hmm, not quite...")
                                    .font(AppTypography.h1)
                                    .foregroundColor(AppColors.textDark)

                                // Confidence badge
                                HStack(spacing: AppSpacing.sm) {
                                    Image(systemName: "gauge.high")
                                        .font(.system(size: 14))
                                    Text("Confidence: \(Int(result.score * 100))%")
                                        .font(AppTypography.body.weight(.medium))
                                }
                                .foregroundColor(AppColors.textMedium)
                                .padding(.horizontal, AppSpacing.lg)
                                .padding(.vertical, AppSpacing.sm)
                                .background(AppColors.sageGreen.opacity(0.2))
                                .cornerRadius(12)

                                // Reason
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

                            // Success state
                            if result.verified && didSaveProof {
                                VStack(spacing: AppSpacing.md) {
                                    HStack(spacing: AppSpacing.sm) {
                                        Image(systemName: "flame.fill")
                                            .foregroundColor(AppColors.sand)
                                        Text("Streak updated!")
                                            .font(AppTypography.h3)
                                            .foregroundColor(AppColors.textDark)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(AppColors.primaryGreen.opacity(0.1))
                                    .cornerRadius(16)

                                    Button("Done") {
                                        dismiss()
                                    }
                                    .font(AppTypography.body.weight(.semibold))
                                    .foregroundColor(AppColors.cardWhite)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppSpacing.lg)
                                    .background(AppColors.primaryGreen)
                                    .cornerRadius(20)
                                }
                                .padding(.horizontal, AppSpacing.lg)
                            }
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
                    Divider()

                    Button {
                        saveProof()
                    } label: {
                        Text("Add to Streak")
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
            } else if let result = result, !result.verified {
                VStack(spacing: 0) {
                    Divider()

                    Button {
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
                    Divider()

                    Button {
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
