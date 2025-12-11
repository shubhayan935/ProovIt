//
//  FindFriendsView.swift
//  SrivastavaShubhayanFinal
//
//  Find Friends from Contacts - Uses Contacts Framework
//  Matches device contacts with app users via phone numbers
//

import SwiftUI

struct FindFriendsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = FindFriendsViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if vm.permissionDenied {
                    // Permission denied state
                    Spacer()
                    VStack(spacing: AppSpacing.lg) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(AppColors.sand)

                        VStack(spacing: AppSpacing.sm) {
                            Text("Contacts Access Required")
                                .font(AppTypography.h2)
                                .foregroundColor(AppColors.textDark)

                            Text("Please enable contacts access in Settings to find friends from your contacts")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textMedium)
                                .multilineTextAlignment(.center)
                        }

                        VStack(spacing: AppSpacing.md) {
                            PrimaryButton(
                                title: "Allow Contacts Access",
                                action: {
                                    Task {
                                        await vm.findFriends()
                                    }
                                }
                            )

                            Button("Open Settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textMedium)
                        }
                    }
                    .padding(.horizontal, AppSpacing.xl)
                    Spacer()
                } else if vm.isLoading {
                    Spacer()
                    VStack(spacing: AppSpacing.lg) {
                        ProgressView()
                            .tint(AppColors.primaryGreen)
                            .scaleEffect(1.5)

                        Text("Finding friends...")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textMedium)
                    }
                    Spacer()
                } else if vm.contactFriends.isEmpty {
                    Spacer()
                    VStack(spacing: AppSpacing.lg) {
                        Image(systemName: "person.2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(AppColors.sand)

                        VStack(spacing: AppSpacing.sm) {
                            Text("No Friends Found")
                                .font(AppTypography.h2)
                                .foregroundColor(AppColors.textDark)

                            Text("None of your contacts are on ProovIt yet. Invite them to join!")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textMedium)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, AppSpacing.xl)
                    Spacer()
                } else {
                    // Friends list
                    ScrollView {
                        VStack(spacing: 0) {
                            // Header
                            HStack {
                                Text("\(vm.contactFriends.count) friends from contacts")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textMedium)
                                Spacer()
                            }
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.md)

                            ForEach(vm.contactFriends) { user in
                                ContactFriendRow(
                                    user: user,
                                    isFollowing: vm.isFollowing(user.id),
                                    onFollowToggle: {
                                        Task {
                                            await vm.toggleFollow(user: user)
                                        }
                                    }
                                )
                                .padding(.leading, AppSpacing.lg)
                            }
                        }
                    }
                }

                if let error = vm.errorMessage {
                    Text(error)
                        .font(AppTypography.caption)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Find Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryGreen)
                }
            }
            .task {
                await vm.findFriends()
            }
        }
    }
}

struct ContactFriendRow: View {
    let user: Profile
    let isFollowing: Bool
    let onFollowToggle: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 44, height: 44)
                .foregroundColor(AppColors.sand)

            VStack(alignment: .leading, spacing: 4) {
                if let fullName = user.full_name {
                    Text(fullName)
                        .font(AppTypography.body.weight(.semibold))
                        .foregroundColor(AppColors.textDark)
                }

                if let username = user.username {
                    Text("@\(username)")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textMedium)
                } else {
                    Text(user.phone_number)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textMedium)
                }
            }

            Spacer()

            Button(action: onFollowToggle) {
                Text(isFollowing ? "Following" : "Follow")
                    .font(AppTypography.caption.weight(.semibold))
                    .foregroundColor(isFollowing ? AppColors.textDark : AppColors.cardWhite)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(isFollowing ? AppColors.cardWhite : AppColors.primaryGreen)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isFollowing ? AppColors.textMedium.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
    }
}
