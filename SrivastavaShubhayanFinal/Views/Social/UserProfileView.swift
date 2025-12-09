//
//  UserProfileView.swift
//  SrivastavaShubhayanFinal
//
//  View other users' profiles
//

import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    let user: Profile
    @StateObject private var vm = UserProfileViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        // Profile header
                        VStack(spacing: AppSpacing.lg) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(AppColors.primaryGreen)

                            VStack(spacing: AppSpacing.sm) {
                                if let fullName = user.full_name {
                                    Text(fullName)
                                        .font(AppTypography.h1)
                                        .foregroundColor(AppColors.textDark)
                                }

                                if let username = user.username {
                                    Text("@\(username)")
                                        .font(AppTypography.body)
                                        .foregroundColor(AppColors.textMedium)
                                }

                                Text("Building habits, one proof at a time")
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textMedium)
                            }
                        }
                        .padding(.top, AppSpacing.md)

                        // Stats
                        AppCard {
                            VStack(spacing: AppSpacing.lg) {
                                HStack {
                                    StatItem(
                                        icon: "flame.fill",
                                        value: "\(vm.activeStreaks)",
                                        label: "Active Streaks"
                                    )

                                    Divider()
                                        .frame(height: 50)

                                    StatItem(
                                        icon: "target",
                                        value: "\(vm.totalGoals)",
                                        label: "Total Goals"
                                    )

                                    Divider()
                                        .frame(height: 50)

                                    StatItem(
                                        icon: "chart.line.uptrend.xyaxis",
                                        value: "\(vm.longestStreak)",
                                        label: "Best Streak"
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)

                        // Follow/Unfollow button
                        Button {
                            Task {
                                await vm.toggleFollow(user: user)
                            }
                        } label: {
                            Text(vm.isFollowing ? "Unfollow" : "Follow")
                                .font(AppTypography.body.weight(.semibold))
                                .foregroundColor(vm.isFollowing ? AppColors.textDark : AppColors.cardWhite)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.lg)
                                .background(vm.isFollowing ? AppColors.cardWhite : AppColors.primaryGreen)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(vm.isFollowing ? AppColors.textMedium.opacity(0.3) : Color.clear, lineWidth: 1.5)
                                )
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.bottom, AppSpacing.xl)
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryGreen)
                }
            }
            .task {
                await vm.loadProfile(userId: user.id)
            }
        }
    }
}
