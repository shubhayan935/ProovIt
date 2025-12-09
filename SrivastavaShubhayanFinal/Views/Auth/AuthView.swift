//
//  AuthView.swift
//  SrivastavaShubhayanFinal
//
//  Authentication Screen - Phone OTP
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

            if vm.showOTPScreen {
                OTPVerificationView(vm: vm)
            } else {
                PhoneNumberEntryView(vm: vm)
            }
        }
    }
}

// Phone Number Entry Screen
struct PhoneNumberEntryView: View {
    @ObservedObject var vm: AuthViewModel
    @FocusState private var isPhoneFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header with app icon
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "leaf.circle.fill")
                    .resizable()
                    .frame(width: 56, height: 56)
                    .foregroundColor(AppColors.primaryGreen)
                    .background(AppColors.sand.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text("Login")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(AppColors.textDark)

                Spacer()
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.top, 60)

            Spacer()
                .frame(height: 40)

            // Phone number field
            HStack {
                Text("Phone number")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textDark)

                Spacer()

                TextField("", text: $vm.phoneNumber)
                    .keyboardType(.phonePad)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textMedium)
                    .multilineTextAlignment(.trailing)
                    .focused($isPhoneFieldFocused)
                    .onChange(of: vm.phoneNumber) { _, newValue in
                        // Limit to 10 digits
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered.count > 10 {
                            vm.phoneNumber = String(filtered.prefix(10))
                        } else {
                            vm.phoneNumber = filtered
                        }
                    }
            }
            .padding()
            .background(AppColors.cardWhite)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
            .padding(.horizontal, AppSpacing.xl)

            Spacer()
                .frame(height: 24)

            // Info text
            Text("Sign up with just your number! We will send you an SMS code in the next step.")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textMedium)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, AppSpacing.xl)

            Spacer()

            // Error message
            if let error = vm.errorMessage {
                Text(error)
                    .font(AppTypography.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.bottom, AppSpacing.md)
            }

            // Continue button
            VStack(spacing: 0) {
                if vm.isLoading {
                    ProgressView()
                        .tint(AppColors.primaryGreen)
                        .frame(height: 56)
                } else {
                    Button {
                        isPhoneFieldFocused = false
                        Task { await vm.sendOTP() }
                    } label: {
                        Text("Continue")
                            .font(AppTypography.body.weight(.semibold))
                            .foregroundColor(AppColors.cardWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.lg)
                            .background(AppColors.primaryGreen)
                            .cornerRadius(16)
                    }
                    .disabled(vm.phoneNumber.filter { $0.isNumber }.count != 10)
                    .opacity(vm.phoneNumber.filter { $0.isNumber }.count == 10 ? 1.0 : 0.5)
                }
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.bottom, 40)
        }
        .onAppear {
            isPhoneFieldFocused = true
        }
    }
}

// OTP Verification Screen
struct OTPVerificationView: View {
    @ObservedObject var vm: AuthViewModel
    @FocusState private var isOTPFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack(spacing: AppSpacing.md) {
                Button(action: { vm.backToPhoneEntry() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.textDark)
                        .frame(width: 44, height: 44)
                        .background(AppColors.cardWhite)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }

                Image(systemName: "leaf.circle.fill")
                    .resizable()
                    .frame(width: 56, height: 56)
                    .foregroundColor(AppColors.primaryGreen)
                    .background(AppColors.sand.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text("Login")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(AppColors.textDark)

                Spacer()
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.top, 60)

            Spacer()
                .frame(height: 40)

            // OTP field
            HStack {
                Text("Verification code")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textDark)

                Spacer()

                TextField("", text: $vm.otp)
                    .keyboardType(.numberPad)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textMedium)
                    .multilineTextAlignment(.trailing)
                    .focused($isOTPFieldFocused)
                    .onChange(of: vm.otp) { _, newValue in
                        // Limit to 3 digits
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered.count > 3 {
                            vm.otp = String(filtered.prefix(3))
                        } else {
                            vm.otp = filtered
                        }
                    }
            }
            .padding()
            .background(AppColors.cardWhite)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
            .padding(.horizontal, AppSpacing.xl)

            Spacer()
                .frame(height: 24)

            // Info text
            Text("Enter the 3-digit code we sent to your phone.")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textMedium)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, AppSpacing.xl)

            Spacer()

            // Error message
            if let error = vm.errorMessage {
                Text(error)
                    .font(AppTypography.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.bottom, AppSpacing.md)
            }

            // Verify button
            VStack(spacing: 0) {
                if vm.isLoading {
                    ProgressView()
                        .tint(AppColors.primaryGreen)
                        .frame(height: 56)
                } else {
                    Button {
                        isOTPFieldFocused = false
                        Task { await vm.verifyOTP() }
                    } label: {
                        Text("Verify")
                            .font(AppTypography.body.weight(.semibold))
                            .foregroundColor(AppColors.cardWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.lg)
                            .background(AppColors.primaryGreen)
                            .cornerRadius(16)
                    }
                    .disabled(vm.otp.count != 3)
                    .opacity(vm.otp.count == 3 ? 1.0 : 0.5)
                }
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.bottom, 40)
        }
        .onAppear {
            isOTPFieldFocused = true
        }
    }
}

// Helper extension to create with environment object
extension AuthView {
    init() {
        self.init(appVM: AppViewModel())
    }
}
