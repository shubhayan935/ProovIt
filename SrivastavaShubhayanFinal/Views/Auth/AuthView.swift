//
//  AuthView.swift
//  SrivastavaShubhayanFinal
//
//  Authentication Screen
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @StateObject private var vm: AuthViewModel

    init(appVM: AppViewModel) {
        _vm = StateObject(wrappedValue: AuthViewModel(appVM: appVM))
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.xl) {
                Spacer()

                // Logo/Title
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "leaf.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(AppColors.primaryGreen)

                    Text("ProovIt")
                        .font(AppTypography.h1)
                        .foregroundColor(AppColors.textDark)

                    Text("Turn habits into streaks")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textMedium)
                }

                Spacer()

                // Input fields
                VStack(spacing: AppSpacing.md) {
                    TextField("Email", text: $vm.email)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)

                    SecureField("Password", text: $vm.password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                }
                .padding(.horizontal, AppSpacing.lg)

                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(AppTypography.caption)
                        .padding(.horizontal, AppSpacing.lg)
                }

                // Buttons
                VStack(spacing: AppSpacing.md) {
                    if vm.isLoading {
                        ProgressView()
                            .tint(AppColors.primaryGreen)
                    } else {
                        PrimaryButton(title: "Log In") {
                            Task { await vm.login() }
                        }
                        .padding(.horizontal, AppSpacing.lg)

                        Button("Sign Up") {
                            Task { await vm.signUp() }
                        }
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.primaryGreen)
                    }
                }

                Spacer()
            }
        }
    }
}

// Helper extension to create with environment object
extension AuthView {
    init() {
        self.init(appVM: AppViewModel())
    }
}
