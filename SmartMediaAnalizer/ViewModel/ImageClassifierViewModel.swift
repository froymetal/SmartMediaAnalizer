//
//  ImageClassifierViewModel.swift
//  SmartMediaAnalizer
//
//  Created by Froylan Almeida on 11/14/25.
//

import SwiftUI
import CoreML
import Vision
import UIKit
import Combine

class ImageClassifierViewModel: ObservableObject {
    @Published var selectedImage: UIImage? // The image selected by the user
    @Published var classificationResult: String = "" // The classification result (name of the detected object)
    @Published var isProcessing: Bool = false // Indicates if the image is being processed
    @Published var errorMessage: String? // Indicates if there is an error

    private var model: VNCoreMLModel? // CoreML model for classification
    
    // MARK: - Initialization
    init() {
        // Load the MobileNetV2 model when initializing the ViewModel
        loadModel()
    }
    
    // MARK: - Model Loading
    /// Loads the MobileNetV2 model from the app bundle
    private func loadModel() {
        // Search for the model file in the bundle
        guard let modelURL = Bundle.main.url(forResource: "MobileNetV2", withExtension: "mlmodelc") ??
                            Bundle.main.url(forResource: "MobileNetV2", withExtension: "mlmodel") else {
            errorMessage = "Could not find MobileNetV2 model"
            return
        }
        
        do {
            // Create an instance of the MLModel
            let mlModel = try MLModel(contentsOf: modelURL)
            
            // Convert MLModel to VNCoreMLModel to use with Vision
            model = try VNCoreMLModel(for: mlModel)
        } catch {
            errorMessage = "Error loading model: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Image Classification
    /// Classifies the selected image using the CoreML model
    func classifyImage() {
        // Verify that there is a selected image
        guard let image = selectedImage else {
            errorMessage = "No image selected"
            return
        }
        
        // Verify that the model is loaded
        guard let model = model else {
            errorMessage = "Model is not available"
            return
        }
        
        // Indicate that processing is in progress
        isProcessing = true
        errorMessage = nil
        classificationResult = ""
        
        // Convert UIImage to CIImage for Vision
        guard let ciImage = CIImage(image: image) else {
            errorMessage = "Could not process the image"
            isProcessing = false
            return
        }
        
        // Create a classification request with Vision
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            // Handle errors
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Classification error: \(error.localizedDescription)"
                    self?.isProcessing = false
                }
                return
            }
            
            // Process the results
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                DispatchQueue.main.async {
                    self?.errorMessage = "Could not obtain results"
                    self?.isProcessing = false
                }
                return
            }
            
            // Update the result on the main thread
            DispatchQueue.main.async {
                // Format the result with the name and confidence
                let confidence = Int(topResult.confidence * 100)
                self?.classificationResult = "\(topResult.identifier)\n(\(confidence)% confidence)"
                self?.isProcessing = false
            }
        }
        
        // Create an image handler to process the request
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        // Execute the request on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error executing classification: \(error.localizedDescription)"
                    self.isProcessing = false
                }
            }
        }
    }
    
    // MARK: - Image Management
    /// Sets the selected image and automatically classifies it
    func setImage(_ image: UIImage?) {
        selectedImage = image
        if image != nil {
            classifyImage()
        } else {
            classificationResult = ""
        }
    }
    
    /// Clears the image and results
    func clearImage() {
        selectedImage = nil
        classificationResult = ""
        errorMessage = nil
    }
}

