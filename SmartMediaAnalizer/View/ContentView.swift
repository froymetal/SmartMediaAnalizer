//
//  ContentView.swift
//  SmartMediaAnalizer
//
//  Created by Froylan Almeida on 11/13/25.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    /// ViewModel that handles image classification logic
    @StateObject private var viewModel = ImageClassifierViewModel()
    
    /// Controls if the gallery image picker is shown
    @State private var showImagePicker = false
    
    /// Controls if the camera picker is shown
    @State private var showCameraPicker = false
    
    /// Defines the source type for the picker
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // MARK: - Image Display Area
                // Area where the selected image is displayed
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                } else {
                    // Placeholder when there is no image
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 300)
                        .overlay(
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("Select an image")
                                    .foregroundColor(.gray)
                                    .padding(.top, 8)
                            }
                        )
                        .padding(.horizontal)
                }
                
                // MARK: - Classification Result
                // Shows the classification result
                if !viewModel.classificationResult.isEmpty {
                    VStack(spacing: 8) {
                        Text("Detected object:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(viewModel.classificationResult)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                // MARK: - Error Message
                // Shows error messages if any
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                // MARK: - Loading Indicator
                // Loading indicator while processing the image
                if viewModel.isProcessing {
                    ProgressView("Processing image...")
                        .padding()
                }
                
                Spacer()
                
                // MARK: - Action Buttons
                // Buttons to select image from gallery or camera
                VStack(spacing: 15) {
                    // Button to select from gallery
                    Button(action: {
                        sourceType = .photoLibrary
                        showImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Select from Gallery")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    
                    // Button to use camera
                    Button(action: {
                        sourceType = .camera
                        showCameraPicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Use Camera")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                    
                    // Button to clear the image
                    if viewModel.selectedImage != nil {
                        Button(action: {
                            viewModel.clearImage()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Clear")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Image Classifier")
            .navigationBarTitleDisplayMode(.inline)
        }
        // MARK: - Sheet Modifiers
        // Presents the gallery image picker
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(
                sourceType: .photoLibrary,
                selectedImage: Binding(
                    get: { viewModel.selectedImage },
                    set: { viewModel.setImage($0) }
                ),
                isPresented: $showImagePicker
            )
        }
        // Presents the camera picker
        .sheet(isPresented: $showCameraPicker) {
            ImagePicker(
                sourceType: .camera,
                selectedImage: Binding(
                    get: { viewModel.selectedImage },
                    set: { viewModel.setImage($0) }
                ),
                isPresented: $showCameraPicker
            )
        }
    }
}

#Preview {
    ContentView()
}
