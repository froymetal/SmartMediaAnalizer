//
//  ImagePicker.swift
//  SmartMediaAnalizer
//
//  Created by Froylan Almeida on 11/14/25.
//

import SwiftUI
import UIKit

/// Enumeration to define the image source (gallery or camera)
enum ImageSource {
    case camera
    case photoLibrary
}

/// SwiftUI wrapper for UIImagePickerController
struct ImagePicker: UIViewControllerRepresentable {
    // MARK: - Properties
    /// The image source (camera or gallery)
    let sourceType: UIImagePickerController.SourceType
    
    /// Binding for the selected image
    @Binding var selectedImage: UIImage?
    
    /// Binding to control if the picker is visible
    @Binding var isPresented: Bool
    
    // MARK: - UIViewControllerRepresentable Methods
    /// Creates the UIImagePickerController
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    /// Updates the view controller (not needed in this case)
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    // MARK: - Coordinator
    /// Creates the coordinator that handles picker events
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// Coordinator that acts as delegate for UIImagePickerController
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        /// Called when the user selects an image
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Get the selected image
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            // Close the picker
            parent.isPresented = false
        }
        
        /// Called when the user cancels the selection
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

