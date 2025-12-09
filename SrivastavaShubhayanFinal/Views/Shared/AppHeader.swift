//
//  AppHeader.swift
//  SrivastavaShubhayanFinal
//
//  Shared UI Component - App Header with Icon
//

import SwiftUI

struct AppHeader: View {
    var showBackButton: Bool = false
    var onBackTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            if showBackButton {
                Button(action: { onBackTap?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.textDark)
                        .frame(width: 22, height: 22)
                        // .background(AppColors.cardWhite)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
            }

            // Spacer()

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

            if showBackButton {
                // Invisible spacer for centering
                Color.clear
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
    }
}
