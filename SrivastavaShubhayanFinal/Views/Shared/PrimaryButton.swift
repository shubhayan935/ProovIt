//
//  PrimaryButton.swift
//  SrivastavaShubhayanFinal
//
//  Shared UI Component - Primary Button
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isFullWidth: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.body.weight(.semibold))
                .foregroundColor(AppColors.cardWhite)
                .padding(.vertical, AppSpacing.md)
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .background(AppColors.primaryGreen)
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}
