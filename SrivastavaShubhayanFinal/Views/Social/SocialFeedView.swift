//
//  SocialFeedView.swift
//  SrivastavaShubhayanFinal
//
//  Social Feed Screen
//

import SwiftUI

struct SocialFeedView: View {
    @StateObject private var vm = FeedViewModel()
    @State private var showUserSearch = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Header with Search
                HStack(spacing: AppSpacing.md) {
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

                    Button(action: { showUserSearch = true }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.cardWhite)
                            .frame(width: 36, height: 36)
                            .background(AppColors.primaryGreen)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)

                if vm.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(AppColors.primaryGreen)
                    Spacer()
                } else if vm.feedProofs.isEmpty {
                    Spacer()
                    VStack(spacing: AppSpacing.lg) {
                        Image(systemName: "person.2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(AppColors.sand)

                        VStack(spacing: AppSpacing.sm) {
                            Text("No activity yet")
                                .font(AppTypography.h2)
                                .foregroundColor(AppColors.textDark)

                            Text("Follow friends to see their proofs")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textMedium)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, AppSpacing.xl)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: AppSpacing.xl) {
                            VStack(spacing: AppSpacing.md) {
                                ForEach(vm.feedProofs) { proof in
                                    FeedProofCard(proof: proof)
                                }
                            }
                        }
                        .padding(.bottom, AppSpacing.xl)
                    }
                    .refreshable {
                        await vm.refresh()
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await vm.refresh()
                }
            }
            .sheet(isPresented: $showUserSearch) {
                UserSearchView()
            }
        }
    }
}

struct FeedProofCard: View {
    let proof: FeedProof
    @State private var proofImage: UIImage?
    @State private var isLoadingImage = true

    private var isCurrentUser: Bool {
        guard let currentUserId = UserSession.shared.userId else { return false }
        return proof.user_id == currentUserId
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Header
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(AppColors.sand)

                VStack(alignment: .leading, spacing: 2) {
                    Text(isCurrentUser ? "\(proof.username) (You)" : proof.username)
                        .font(AppTypography.body.weight(.semibold))
                        .foregroundColor(AppColors.textDark)

                    if let date = proof.created_at {
                        Text(timeAgo(from: date))
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textMedium)
                    }
                }

                Spacer()

                if proof.verified {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(AppColors.primaryGreen)
                }
            }
            .padding(.horizontal, AppSpacing.lg)

            // Goal title
            Text(proof.goal_title)
                .font(AppTypography.h3)
                .foregroundColor(AppColors.textDark)
                .padding(.horizontal, AppSpacing.lg)

            // Caption
            if let caption = proof.caption {
                Text(caption)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textMedium)
                    .padding(.horizontal, AppSpacing.lg)
            }

            // Proof Image
            if let image = proofImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .clipped()
                    // .cornerRadius(12)
            } else if isLoadingImage {
                RoundedRectangle(cornerRadius: 0)
                    .fill(AppColors.sageGreen.opacity(0.3))
                    .frame(height: 300)
                    .overlay(
                        ProgressView()
                            .tint(AppColors.primaryGreen)
                    )
            } else {
                RoundedRectangle(cornerRadius: 0)
                    .fill(AppColors.sageGreen.opacity(0.3))
                    .frame(height: 300)
                    .overlay(
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(AppColors.sand)
                    )
            }
        }
        .padding(.vertical, AppSpacing.md)
        .task {
            await loadImage()
        }
    }

    private func loadImage() async {
        isLoadingImage = true
        defer { isLoadingImage = false }

        do {
            // Get public URL from Supabase Storage
            guard let publicURL = ImageUploadService.shared.getPublicURL(for: proof.image_path) else {
                
                return
            }

            

            // Download image data
            let (data, response) = try await URLSession.shared.data(from: publicURL)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                
                return
            }

            // Convert to UIImage
            if let image = UIImage(data: data) {
                proofImage = image
                
            } else {
                
            }

        } catch {
            print("Failed to load proof image: \(error.localizedDescription)")
        }
    }

    private func timeAgo(from date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        let minutes = Int(seconds / 60)
        let hours = Int(seconds / 3600)
        let days = Int(seconds / 86400)

        if days > 0 {
            return "\(days)d ago"
        } else if hours > 0 {
            return "\(hours)h ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "just now"
        }
    }
}
