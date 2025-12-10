//
//  ProofCaptureView.swift
//  SrivastavaShubhayanFinal
//
//  Proof Capture Screen - Camera/Photo Picker
//

import SwiftUI
import PhotosUI

struct ProofCaptureView: View {
    let goal: Goal

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showCamera = false
    @State private var navigateToResult = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack(spacing: AppSpacing.md) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.textDark)
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }

                Spacer()

                StepIndicator(currentStep: selectedImageData == nil ? 1 : 2, totalSteps: 3)

                Spacer()

                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)

            // Main content + scroll
            ScrollView {
                VStack(spacing: 0) {
                    GoalHeaderView(goal: goal)

                    if let imageData = selectedImageData,
                       let uiImage = UIImage(data: imageData) {
                        ImagePreviewSection(image: uiImage)
                    } else {
                        CaptureSection()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.top, AppSpacing.lg)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if selectedImageData == nil {
                CaptureButtons(selectedItem: $selectedItem, showCamera: $showCamera)
                    .padding(.vertical, AppSpacing.lg)
                    .background(AppColors.background)
            } else {
                NextButtonBar(action: { navigateToResult = true })
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView { imageData in
                selectedImageData = imageData
                showCamera = false
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            if let imageData = selectedImageData {
                AIResultView(goal: goal, imageData: imageData)
            }
        }
    }
}

struct GoalHeaderView: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.sand)

                Text(goal.title)
                    .font(AppTypography.h2)
                    .foregroundColor(AppColors.textDark)
            }

            if let desc = goal.description {
                Text(desc)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textMedium)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.md)
    }
}

struct ImagePreviewSection: View {
    let image: UIImage

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            // Success message
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.primaryGreen)
                Text("Perfect! Scan now.")
                    .font(AppTypography.h2)
                    .foregroundColor(AppColors.textDark)
            }
            .padding(.top, AppSpacing.lg)

            // Image preview card
            ImagePreviewCard(image: image)

            // Tips
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                TipRow(icon: "camera.viewfinder", text: "Make sure the proof is clearly visible")
                TipRow(icon: "light.max", text: "Ensure good lighting for best results")
                TipRow(icon: "checkmark.seal", text: "AI will verify this matches your goal")
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }
}

struct ImagePreviewCard: View {
    let image: UIImage

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 350)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                AppColors.primaryGreen.opacity(0.5),
                                AppColors.sageGreen.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
            )
            .shadow(color: AppColors.primaryGreen.opacity(0.2), radius: 12, x: 0, y: 4)
            .padding(.horizontal, AppSpacing.lg)
    }
}

struct CaptureSection: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("UploadStimulus")
                .resizable()
                .scaledToFit()
                .frame(height: 480)
                .foregroundColor(AppColors.sand)
        }
    }
}

struct CaptureButtons: View {
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var showCamera: Bool

    var body: some View {
        VStack(alignment: .center, spacing: AppSpacing.md) {
//             PhotosPicker(selection: $selectedItem, matching: .images) {
//                 HStack(spacing: AppSpacing.sm) {
//                     Image(systemName: "photo.on.rectangle")
//                     Text("Choose from Library")
//                         .font(AppTypography.body.weight(.semibold))
//                 }
//                 .foregroundColor(AppColors.cardWhite)
//                 .padding(.vertical, AppSpacing.lg)
//                 .frame(maxWidth: .infinity)
//                 .background(AppColors.primaryGreen)
//                 .cornerRadius(20)
//             }

            PrimaryButton(
                title: "Take Photo",
                icon: "camera.fill",
                action: { showCamera = true }
            )
        }
        .padding(.horizontal, AppSpacing.lg)
    }
}

struct NextButtonBar: View {
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            PrimaryButton(title: "Scan", action: action)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.lg)
        }
        .background(AppColors.background)
    }
}

struct TipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.textDark.opacity(0.6))
                .frame(width: 24)

            Text(text)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textMedium)

            Spacer()
        }
    }
}

// Simple camera wrapper
struct CameraView: UIViewControllerRepresentable {
    let onCapture: (Data) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (Data) -> Void

        init(onCapture: @escaping (Data) -> Void) {
            self.onCapture = onCapture
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.8) {
                onCapture(data)
            }
        }
    }
}

#Preview {
    ProofCaptureView(
        goal: Goal(
            id: UUID(),
            user_id: UUID(),
            title: "See Flowers",
            description: "Find and photograph beautiful flowers in nature",
            frequency: "daily",
            is_active: true,
            created_at: Date()
        )
    )
}
