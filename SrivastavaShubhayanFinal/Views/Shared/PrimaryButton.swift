//
//  PrimaryButton.swift
//  SrivastavaShubhayanFinal
//
//  Shared UI Component - Primary Button
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var isFullWidth: Bool = true

    init(title: String, icon: String? = nil, action: @escaping () -> Void, isFullWidth: Bool = true) {
        self.title = title
        self.icon = icon
        self.action = action
        self.isFullWidth = isFullWidth
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(AppTypography.body.weight(.semibold))
            }
            .foregroundColor(AppColors.cardWhite)
            .padding(.vertical, AppSpacing.lg)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(AppColors.primaryGreen)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}
