//
//  OnboardingView.swift
//  SrivastavaShubhayanFinal
//
//  User Onboarding - Collect full name and username
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var vm = OnboardingViewModel()
    @FocusState private var fullNameFocused: Bool

    var phoneNumber: String
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            AppHeader()

            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    // Welcome message
                    VStack(spacing: AppSpacing.sm) {
                        Text("Welcome to ProovIt!")
                            .font(AppTypography.h1)
                            .foregroundColor(AppColors.textDark)

                        Text("Let's set up your profile")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textMedium)
                    }
                    .padding(.top, AppSpacing.xl)

                    // Full name field
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack {
                            Text("Full name")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textDark)

                            Spacer()

                            TextField("", text: $vm.fullName)
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textMedium)
                                .multilineTextAlignment(.trailing)
                                .focused($fullNameFocused)
                        }
                        .padding()
                        .background(AppColors.cardWhite)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
                    }

                    // Username field
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack {
                            Text("Username")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textDark)

                            Spacer()

                            TextField("", text: $vm.username)
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textMedium)
                                .multilineTextAlignment(.trailing)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }
                        .padding()
                        .background(AppColors.cardWhite)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)

                        Text("This will be visible to other users")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textMedium)
                    }

                    // Error message
                    if let error = vm.errorMessage {
                        Text(error)
                            .font(AppTypography.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, 120)
            }

            // Continue button
            VStack(spacing: 0) {
                Divider()

                if vm.isLoading {
                    ProgressView()
                        .tint(AppColors.primaryGreen)
                        .frame(height: 56)
                } else {
                    Button {
                        fullNameFocused = false
                        Task {
                            await vm.createProfile(phoneNumber: phoneNumber)
                            if vm.profileCreated {
                                onComplete()
                            }
                        }
                    } label: {
                        Text("Continue")
                            .font(AppTypography.body.weight(.semibold))
                            .foregroundColor(AppColors.cardWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.lg)
                            .background(AppColors.primaryGreen)
                            .cornerRadius(16)
                    }
                    .disabled(!vm.canContinue)
                    .opacity(vm.canContinue ? 1.0 : 0.5)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.lg)
            .background(AppColors.background)
        }
        .background(AppColors.background.ignoresSafeArea())
        .onAppear {
            fullNameFocused = true
        }
    }
}
