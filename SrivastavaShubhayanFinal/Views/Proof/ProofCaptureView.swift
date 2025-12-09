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
                        .background(AppColors.cardWhite)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }

                Spacer()

                StepIndicator(currentStep: selectedImageData == nil ? 1 : 2, totalSteps: 3)

                Spacer()

                // Invisible spacer for centering
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)

            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    // Goal context
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
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

                    // Selected image preview
                    if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                        VStack(spacing: AppSpacing.xl) {
                            // Success message
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppColors.primaryGreen)
                                Text("Perfect! Scan now.")
                                    .font(AppTypography.h3)
                                    .foregroundColor(AppColors.textDark)
                            }
                            .padding(.top, AppSpacing.md)

                            // Image preview
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 350)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [AppColors.primaryGreen.opacity(0.5), AppColors.sageGreen.opacity(0.3)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                )
                                .shadow(color: AppColors.primaryGreen.opacity(0.2), radius: 12, x: 0, y: 4)
                                .padding(.horizontal, AppSpacing.lg)

                            // Tips
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                TipRow(icon: "camera.viewfinder", text: "Make sure the proof is clearly visible")
                                TipRow(icon: "light.max", text: "Ensure good lighting for best results")
                                TipRow(icon: "checkmark.seal", text: "AI will verify this matches your goal")
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                    } else {
                        VStack(spacing: AppSpacing.xl) {
                            // Camera icon
                            Image(systemName: "camera.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .foregroundColor(AppColors.sand)
                                .padding(.top, 40)

                            VStack(spacing: AppSpacing.sm) {
                                Text("Capture your proof")
                                    .font(AppTypography.h1)
                                    .foregroundColor(AppColors.textDark)

                                Text("Take a photo or choose from your library")
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textMedium)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, AppSpacing.xl)

                            // Buttons
                            VStack(spacing: AppSpacing.md) {
                                PhotosPicker(selection: $selectedItem, matching: .images) {
                                    HStack(spacing: AppSpacing.sm) {
                                        Image(systemName: "photo.on.rectangle")
                                        Text("Choose from Library")
                                            .font(AppTypography.body.weight(.semibold))
                                    }
                                    .foregroundColor(AppColors.cardWhite)
                                    .padding(.vertical, AppSpacing.lg)
                                    .frame(maxWidth: .infinity)
                                    .background(AppColors.textDark)
                                    .cornerRadius(20)
                                }

                                Button {
                                    showCamera = true
                                } label: {
                                    HStack(spacing: AppSpacing.sm) {
                                        Image(systemName: "camera.fill")
                                        Text("Take Photo")
                                            .font(AppTypography.body.weight(.semibold))
                                    }
                                    .foregroundColor(AppColors.textDark)
                                    .padding(.vertical, AppSpacing.lg)
                                    .frame(maxWidth: .infinity)
                                    .background(AppColors.cardWhite)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(AppColors.textDark.opacity(0.2), lineWidth: 1.5)
                                    )
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                    }
                }
                .padding(.bottom, 120) // Space for bottom button
            }

            // Bottom button
            if selectedImageData != nil {
                VStack(spacing: 0) {
                    Divider()

                    Button {
                        navigateToResult = true
                    } label: {
                        Text("Next")
                            .font(AppTypography.body.weight(.semibold))
                            .foregroundColor(AppColors.cardWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.lg)
                            .background(AppColors.textDark)
                            .cornerRadius(20)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.lg)
                    .background(AppColors.background)
                }
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
