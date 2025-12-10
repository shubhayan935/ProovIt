//
//  ProfileView.swift
//  SrivastavaShubhayanFinal
//
//  Profile Screen
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @StateObject private var vm = ProfileViewModel()

    var greeting: String {
        if let name = UserSession.shared.currentProfile?.full_name {
            return "Hi, \(name)"
        }
        return "Hi there"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Header
                AppHeader()

                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        // Profile header
                        VStack(spacing: AppSpacing.lg) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(AppColors.primaryGreen)

                            VStack(spacing: AppSpacing.sm) {
                                Text(greeting)
                                    .font(AppTypography.h1)
                                    .foregroundColor(AppColors.textDark)

                                HStack(spacing: AppSpacing.md) {
                                    HStack(spacing: 4) {
                                        Text("\(vm.followersCount)")
                                            .font(AppTypography.body.weight(.semibold))
                                            .foregroundColor(AppColors.textDark)
                                        Text("followers")
                                            .font(AppTypography.body)
                                            .foregroundColor(AppColors.textMedium)
                                    }

                                    Text("•")
                                        .foregroundColor(AppColors.textMedium)

                                    HStack(spacing: 4) {
                                        Text("\(vm.followingCount)")
                                            .font(AppTypography.body.weight(.semibold))
                                            .foregroundColor(AppColors.textDark)
                                        Text("following")
                                            .font(AppTypography.body)
                                            .foregroundColor(AppColors.textMedium)
                                    }
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

                        // Spacer()

                        // Logout button
                        Button {
                            appVM.logout()
                        } label: {
                            Text("Log Out")
                                .font(AppTypography.body.weight(.semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.lg)
                                .background(AppColors.cardWhite)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1.5)
                                )
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.bottom, AppSpacing.xl)
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarHidden(true)
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
