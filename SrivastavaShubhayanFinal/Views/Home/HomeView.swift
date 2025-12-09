//
//  HomeView.swift
//  SrivastavaShubhayanFinal
//
//  Home Screen - Today's Goals
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Header
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Today's Goals")
                                .font(AppTypography.h1)
                                .foregroundColor(AppColors.textDark)

                            Text("Tap a goal to log your proof")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textMedium)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppSpacing.lg)

                        if vm.isLoading {
                            ProgressView()
                                .tint(AppColors.primaryGreen)
                                .padding(.top, AppSpacing.xl)
                        } else if vm.goals.isEmpty {
                            VStack(spacing: AppSpacing.md) {
                                Image(systemName: "target")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(AppColors.sand)

                                Text("No goals yet")
                                    .font(AppTypography.h3)
                                    .foregroundColor(AppColors.textDark)

                                Text("Create your first goal to get started")
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textMedium)
                            }
                            .padding(.top, AppSpacing.xl)
                        } else {
                            ForEach(vm.goals) { goal in
                                NavigationLink {
                                    ProofCaptureView(goal: goal)
                                } label: {
                                    GoalCard(goal: goal)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                    }
                    .padding(.vertical, AppSpacing.lg)
                }
            }
        }
    }
}

struct GoalCard: View {
    let goal: Goal

    var body: some View {
        AppCard {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(goal.title)
                        .font(AppTypography.h3)
                        .foregroundColor(AppColors.textDark)

                    if let desc = goal.description, !desc.isEmpty {
                        Text(desc)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textMedium)
                    }

                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(AppColors.sand)
                        Text(goal.frequency.replacingOccurrences(of: "_", with: " "))
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textMedium)
                    }
                }

                Spacer()

                Image(systemName: "camera.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(AppColors.primaryGreen)
            }
        }
    }
}
