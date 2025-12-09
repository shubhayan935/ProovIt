//
//  StepIndicator.swift
//  SrivastavaShubhayanFinal
//
//  Shared UI Component - Step Progress Indicator
//

import SwiftUI

struct StepIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step == currentStep ? AppColors.textDark : AppColors.textDark.opacity(0.2))
                    .frame(width: step == currentStep ? 32 : 32, height: 32)
                    .overlay(
                        Text("\(step)")
                            .font(.system(size: 14, weight: step == currentStep ? .semibold : .regular))
                            .foregroundColor(step == currentStep ? AppColors.cardWhite : AppColors.textMedium)
                    )
            }
        }
    }
}
