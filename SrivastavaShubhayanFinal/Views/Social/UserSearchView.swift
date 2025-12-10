//
//  UserSearchView.swift
//  SrivastavaShubhayanFinal
//
//  User Search Screen - Find and follow users
//

import SwiftUI

struct UserSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = UserSearchViewModel()
    @State private var selectedUser: Profile?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: AppSpacing.md) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppColors.textMedium)

                        TextField("Search users...", text: $vm.searchText)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textDark)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .onChange(of: vm.searchText) { _, newValue in
                                Task {
                                    await vm.searchUsers()
                                }
                            }

                        if !vm.searchText.isEmpty {
                            Button(action: {
                                vm.searchText = ""
                                vm.searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppColors.textMedium)
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColors.cardWhite)
                    .cornerRadius(12)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)

                // Results
                if vm.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(AppColors.primaryGreen)
                    Spacer()
                } else if vm.searchResults.isEmpty && !vm.searchText.isEmpty {
                    Spacer()
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "person.fill.questionmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(AppColors.sand)

                        Text("No users found")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textMedium)
                    }
                    Spacer()
                } else if vm.searchResults.isEmpty {
                    Spacer()
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(AppColors.sand)

                        Text("Search for users to follow")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textMedium)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(vm.searchResults) { user in
                                UserSearchResultRow(
                                    user: user,
                                    isFollowing: vm.isFollowing(user.id),
                                    onFollowToggle: {
                                        Task {
                                            await vm.toggleFollow(user: user)
                                        }
                                    },
                                    onProfileTap: {
                                        selectedUser = user
                                    }
                                )
                                    .padding(.leading, AppSpacing.lg)
                            }
                        }
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Find Users")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryGreen)
                }
            }
            .sheet(item: $selectedUser) { user in
                UserProfileView(user: user)
            }
        }
    }
}

struct UserSearchResultRow: View {
    let user: Profile
    let isFollowing: Bool
    let onFollowToggle: () -> Void
    let onProfileTap: () -> Void

    var body: some View {
        Button(action: onProfileTap) {
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
        .buttonStyle(PlainButtonStyle())
    }
}
