//
//  SocialFeedView.swift
//  SrivastavaShubhayanFinal
//
//  Social Feed Screen
//

import SwiftUI

struct SocialFeedView: View {
    @State private var mockProofs: [FeedProof] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(AppColors.primaryGreen)
                } else if mockProofs.isEmpty {
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "person.2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(AppColors.sand)

                        Text("No activity yet")
                            .font(AppTypography.h3)
                            .foregroundColor(AppColors.textDark)

                        Text("Follow friends to see their proofs")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textMedium)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: AppSpacing.lg) {
                            ForEach(mockProofs) { proof in
                                FeedProofCard(proof: proof)
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.lg)
                    }
                }
            }
            .navigationTitle("Social Feed")
        }
        .task {
            await loadFeed()
        }
    }

    private func loadFeed() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Mock data
        mockProofs = [
            FeedProof(
                id: UUID(),
                goal_id: UUID(),
                user_id: UUID(),
                image_path: "mock1.jpg",
                caption: "Morning run done!",
                verified: true,
                verification_score: 0.92,
                created_at: Date(),
                goal_title: "Exercise for 30 minutes",
                username: "sarah_runner"
            ),
            FeedProof(
                id: UUID(),
                goal_id: UUID(),
                user_id: UUID(),
                image_path: "mock2.jpg",
                caption: nil,
                verified: true,
                verification_score: 0.88,
                created_at: Date().addingTimeInterval(-3600),
                goal_title: "Drink 8 glasses of water",
                username: "hydro_mike"
            ),
            FeedProof(
                id: UUID(),
                goal_id: UUID(),
                user_id: UUID(),
                image_path: "mock3.jpg",
                caption: "Chapter 5 completed!",
                verified: true,
                verification_score: 0.95,
                created_at: Date().addingTimeInterval(-7200),
                goal_title: "Read for 20 minutes",
                username: "bookworm_jane"
            )
        ]

        isLoading = false
    }
}

struct FeedProofCard: View {
    let proof: FeedProof

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // Header
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(AppColors.sand)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(proof.username)
                            .font(AppTypography.body.weight(.semibold))
                            .foregroundColor(AppColors.textDark)

                        if let date = proof.created_at {
                            Text(timeAgo(from: date))
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textMedium)
                        }
                    }

                    Spacer()

                    if proof.verified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(AppColors.primaryGreen)
                    }
                }

                // Goal title
                Text(proof.goal_title)
                    .font(AppTypography.h3)
                    .foregroundColor(AppColors.textDark)

                // Caption
                if let caption = proof.caption {
                    Text(caption)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textMedium)
                }

                // Image placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.sageGreen.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(AppColors.sand)
                    )

                // Stats
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(AppColors.sand)
                    Text("Streak continues!")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textMedium)
                }
            }
        }
    }

    private func timeAgo(from date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        let minutes = Int(seconds / 60)
        let hours = Int(seconds / 3600)
        let days = Int(seconds / 86400)

        if days > 0 {
            return "\(days)d ago"
        } else if hours > 0 {
            return "\(hours)h ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "just now"
        }
    }
}
