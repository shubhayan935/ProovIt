//
//  CreateGoalView.swift
//  SrivastavaShubhayanFinal
//
//  Create Goal Screen
//

import SwiftUI

struct CreateGoalView: View {
    @StateObject private var vm = CreateGoalViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var titleFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
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

                Text("New Goal")
                    .font(AppTypography.h2)
                    .foregroundColor(AppColors.textDark)

                Spacer()
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)

            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    // Title field
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("What's your goal?")
                            .font(AppTypography.h3)
                            .foregroundColor(AppColors.textDark)

                        TextField("e.g., Drink 8 glasses of water", text: $vm.title)
                            .font(AppTypography.body)
                            .padding()
                            .background(AppColors.cardWhite)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
                            .focused($titleFieldFocused)
                    }
                    .padding(.horizontal, AppSpacing.lg)

                    // Description field
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Description (optional)")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textMedium)

                        TextField("Add more details...", text: $vm.description, axis: .vertical)
                            .font(AppTypography.body)
                            .lineLimit(3...6)
                            .padding()
                            .background(AppColors.cardWhite)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
                    }
                    .padding(.horizontal, AppSpacing.lg)

                    // Frequency selector
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("How often?")
                            .font(AppTypography.h3)
                            .foregroundColor(AppColors.textDark)

                        VStack(spacing: AppSpacing.sm) {
                            ForEach(vm.frequencyOptions, id: \.self) { frequency in
                                FrequencyOptionButton(
                                    frequency: frequency,
                                    displayName: vm.frequencyDisplayName(frequency),
                                    isSelected: vm.selectedFrequency == frequency
                                ) {
                                    vm.selectedFrequency = frequency
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)

                    // Error message
                    if let error = vm.errorMessage {
                        Text(error)
                            .font(AppTypography.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, AppSpacing.lg)
                    }
                }
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, 120)
            }

            // Create button
            VStack(spacing: 0) {
                Divider()

                if vm.isLoading {
                    ProgressView()
                        .tint(AppColors.primaryGreen)
                        .frame(height: 56)
                } else {
                    Button {
                        titleFieldFocused = false
                        Task {
                            await vm.createGoal()
                            if vm.goalCreated {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Create Goal")
                            .font(AppTypography.body.weight(.semibold))
                            .foregroundColor(AppColors.cardWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.lg)
                            .background(AppColors.primaryGreen)
                            .cornerRadius(16)
                    }
                    .disabled(!vm.canSave)
                    .opacity(vm.canSave ? 1.0 : 0.5)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.lg)
            .background(AppColors.background)
        }
        .background(AppColors.background.ignoresSafeArea())
        .onAppear {
            titleFieldFocused = true
        }
    }
}

struct FrequencyOptionButton: View {
    let frequency: String
    let displayName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(displayName)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textDark)

                    Text(frequencySubtitle)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textMedium)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.primaryGreen)
                        .font(.system(size: 24))
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(AppColors.textMedium.opacity(0.3))
                        .font(.system(size: 24))
                }
            }
            .padding()
            .background(isSelected ? AppColors.primaryGreen.opacity(0.1) : AppColors.cardWhite)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppColors.primaryGreen : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    var frequencySubtitle: String {
        switch frequency {
        case "daily": return "Build a daily habit"
        case "3_per_week": return "Perfect for workouts"
        case "5_per_week": return "Weekday routine"
        case "weekly": return "Once a week is great"
        default: return ""
        }
    }
}
