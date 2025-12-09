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

    var body: some View {
        ZStack {
            AppColors.sageGreen.opacity(0.1)
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.xl) {
                // Goal info
                AppCard {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text(goal.title)
                            .font(AppTypography.h2)
                            .foregroundColor(AppColors.textDark)

                        if let desc = goal.description {
                            Text(desc)
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textMedium)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)

                Spacer()

                // Selected image preview
                if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                    VStack(spacing: AppSpacing.md) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 8)

                        PrimaryButton(title: "Verify with AI") {
                            navigateToResult = true
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }
                } else {
                    VStack(spacing: AppSpacing.lg) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(AppColors.sand)

                        Text("Choose how to capture your proof")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textMedium)
                            .multilineTextAlignment(.center)

                        VStack(spacing: AppSpacing.md) {
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                HStack {
                                    Image(systemName: "photo.on.rectangle")
                                    Text("Choose from Library")
                                        .font(AppTypography.body.weight(.semibold))
                                }
                                .foregroundColor(AppColors.cardWhite)
                                .padding(.vertical, AppSpacing.md)
                                .frame(maxWidth: .infinity)
                                .background(AppColors.primaryGreen)
                                .cornerRadius(16)
                            }

                            Button {
                                showCamera = true
                            } label: {
                                HStack {
                                    Image(systemName: "camera")
                                    Text("Take Photo")
                                        .font(AppTypography.body.weight(.semibold))
                                }
                                .foregroundColor(AppColors.primaryGreen)
                                .padding(.vertical, AppSpacing.md)
                                .frame(maxWidth: .infinity)
                                .background(AppColors.cardWhite)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.primaryGreen, lineWidth: 2)
                                )
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }
                }

                Spacer()
            }
            .padding(.top, AppSpacing.lg)
        }
        .navigationTitle("Log Proof")
        .navigationBarTitleDisplayMode(.inline)
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
