//
//  SocialFeedView.swift
//  SrivastavaShubhayanFinal
//
//  Social Feed Screen
//

import SwiftUI

struct SocialFeedView: View {
    @StateObject private var vm = FeedViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Header
                AppHeader()

                if vm.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(AppColors.primaryGreen)
                    Spacer()
                } else if vm.feedProofs.isEmpty {
                    Spacer()
                    VStack(spacing: AppSpacing.lg) {
                        Image(systemName: "person.2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(AppColors.sand)

                        VStack(spacing: AppSpacing.sm) {
                            Text("No activity yet")
                                .font(AppTypography.h2)
                                .foregroundColor(AppColors.textDark)

                            Text("Follow friends to see their proofs")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textMedium)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, AppSpacing.xl)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: AppSpacing.xl) {
                            VStack(spacing: AppSpacing.md) {
                                ForEach(vm.feedProofs) { proof in
                                    FeedProofCard(proof: proof)
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                        .padding(.bottom, AppSpacing.xl)
                    }
                    .refreshable {
                        await vm.refresh()
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

struct FeedProofCard: View {
    let proof: FeedProof

    var body: some View {
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

            // Divider between posts
            Divider()
                .padding(.top, AppSpacing.sm)
        }
        .padding(.vertical, AppSpacing.md)
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
