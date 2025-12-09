//
//  ProfileView.swift
//  SrivastavaShubhayanFinal
//
//  Profile Screen
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appVM: AppViewModel

    @State private var username = "demo_user"
    @State private var activeStreaks = 3
    @State private var totalGoals = 5
    @State private var longestStreak = 12

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        // Profile header
                        VStack(spacing: AppSpacing.md) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(AppColors.primaryGreen)

                            Text(username)
                                .font(AppTypography.h2)
                                .foregroundColor(AppColors.textDark)
                        }
                        .padding(.top, AppSpacing.xl)

                        // Stats
                        AppCard {
                            VStack(spacing: AppSpacing.lg) {
                                HStack {
                                    StatItem(
                                        icon: "flame.fill",
                                        value: "\(activeStreaks)",
                                        label: "Active Streaks"
                                    )

                                    Divider()
                                        .frame(height: 50)

                                    StatItem(
                                        icon: "target",
                                        value: "\(totalGoals)",
                                        label: "Total Goals"
                                    )

                                    Divider()
                                        .frame(height: 50)

                                    StatItem(
                                        icon: "chart.line.uptrend.xyaxis",
                                        value: "\(longestStreak)",
                                        label: "Best Streak"
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)

                        // Achievement section
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Achievements")
                                .font(AppTypography.h3)
                                .foregroundColor(AppColors.textDark)

                            AppCard {
                                HStack {
                                    Image(systemName: "trophy.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(AppColors.sand)

                                    VStack(alignment: .leading) {
                                        Text("Consistency Champion")
                                            .font(AppTypography.body.weight(.semibold))
                                            .foregroundColor(AppColors.textDark)

                                        Text("Completed 7 days in a row")
                                            .font(AppTypography.caption)
                                            .foregroundColor(AppColors.textMedium)
                                    }

                                    Spacer()
                                }
                            }

                            AppCard {
                                HStack {
                                    Image(systemName: "leaf.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(AppColors.primaryGreen)

                                    VStack(alignment: .leading) {
                                        Text("Getting Started")
                                            .font(AppTypography.body.weight(.semibold))
                                            .foregroundColor(AppColors.textDark)

                                        Text("Created your first goal")
                                            .font(AppTypography.caption)
                                            .foregroundColor(AppColors.textMedium)
                                    }

                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)

                        // Logout button
                        PrimaryButton(title: "Log Out") {
                            appVM.logout()
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.bottom, AppSpacing.xl)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primaryGreen)
                .font(.system(size: 24))

            Text(value)
                .font(AppTypography.h2)
                .foregroundColor(AppColors.textDark)

            Text(label)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textMedium)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
