//
//  AppCard.swift
//  SrivastavaShubhayanFinal
//
//  Shared UI Component - Card Container
//

import SwiftUI

struct AppCard<Content: View>: View {
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm, content: content)
            .padding(AppSpacing.lg)
            .background(AppColors.cardWhite)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}
