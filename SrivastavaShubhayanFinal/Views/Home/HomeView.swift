//
//  HomeView.swift
//  SrivastavaShubhayanFinal
//
//  Home Screen - Today's Goals
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @State private var showCreateGoal = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with Add button
                HStack(spacing: AppSpacing.md) {
                    // App Icon + Name
                    HStack(spacing: AppSpacing.sm) {
                        Image("AppLogo")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Text("ProovIt")
                            .font(AppTypography.h3)
                            .foregroundColor(AppColors.textDark)
                    }

                    Spacer()

                    // Add Goal button
                    Button(action: { showCreateGoal = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.cardWhite)
                            .frame(width: 36, height: 36)
                            .background(AppColors.primaryGreen)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)

                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        // Title Section
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Today's Goals")
                                .font(AppTypography.h2)
                                .foregroundColor(AppColors.textDark)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.md)

                        if vm.isLoading {
                            ProgressView()
                                .tint(AppColors.primaryGreen)
                                .padding(.top, AppSpacing.xl)
                        } else if vm.goals.isEmpty {
                            VStack(spacing: AppSpacing.md) {
                                Image(systemName: "target")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(AppColors.sand)
                                    .padding(.top, 60)

                                Text("No goals yet")
                                    .font(AppTypography.h2)
                                    .foregroundColor(AppColors.textDark)

                                Text("Create your first goal to get started")
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textMedium)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, AppSpacing.xl)
                        } else {
                            VStack(spacing: AppSpacing.md) {
                                ForEach(vm.goals) { goal in
                                    NavigationLink {
                                        ProofCaptureView(goal: goal)
                                    } label: {
                                        GoalCard(goal: goal)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                    }
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showCreateGoal) {
                CreateGoalView()
                    .onDisappear {
                        // Refresh goals after creating
                        Task {
                            await vm.loadGoals()
                        }
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
