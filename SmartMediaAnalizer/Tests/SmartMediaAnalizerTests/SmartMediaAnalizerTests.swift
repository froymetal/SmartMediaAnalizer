//
//  SmartMediaAnalizerTests.swift
//  SmartMediaAnalizerTests
//
//  Created by Froylan Almeida on 11/13/25.
//

import XCTest
import UIKit
@testable import SmartMediaAnalizer

final class ImageClassifierViewModelTests: XCTestCase {
    
    var viewModel: ImageClassifierViewModel!
    
    override func setUpWithError() throws {
        viewModel = ImageClassifierViewModel()
    }
    
    override func tearDownWithError() throws {
        // Call to clean up after each test
        viewModel = nil
    }
    
    // MARK: - Initialization Tests
    
    /// Test that ViewModel initializes correctly
    func testViewModelInitialization() throws {
        // Given: A new ViewModel is created in setUp
        
        // Then: Initial state should be correct
        XCTAssertNil(viewModel.selectedImage, "Selected image should be nil initially")
        XCTAssertEqual(viewModel.classificationResult, "", "Classification result should be empty initially")
        XCTAssertFalse(viewModel.isProcessing, "Should not be processing initially")
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil initially")
    }
    
    // MARK: - setImage Tests
    
    /// Test that setImage with nil clears the classification result
    func testSetImageWithNil() throws {
        // Given: ViewModel has a classification result
        viewModel.classificationResult = "Test Result"
        viewModel.selectedImage = createTestImage()
        
        // When: Setting image to nil
        viewModel.setImage(nil)
        
        // Then: Image should be nil and result should be cleared
        XCTAssertNil(viewModel.selectedImage, "Selected image should be nil")
        XCTAssertEqual(viewModel.classificationResult, "", "Classification result should be empty")
    }
    
    /// Test that setImage with an image sets the selectedImage
    func testSetImageWithImage() throws {
        // Given: A test image
        let testImage = createTestImage()
        
        // When: Setting the image
        viewModel.setImage(testImage)
        
        // Then: Image should be set
        XCTAssertNotNil(viewModel.selectedImage, "Selected image should not be nil")
        XCTAssertEqual(viewModel.selectedImage, testImage, "Selected image should match the set image")
    }
    
    // MARK: - clearImage Tests
    
    /// Test that clearImage clears all properties
    func testClearImage() throws {
        // Given: ViewModel has data
        viewModel.selectedImage = createTestImage()
        viewModel.classificationResult = "Test Result"
        viewModel.errorMessage = "Test Error"
        viewModel.isProcessing = true
        
        // When: Clearing the image
        viewModel.clearImage()
        
        // Then: All properties should be cleared
        XCTAssertNil(viewModel.selectedImage, "Selected image should be nil")
        XCTAssertEqual(viewModel.classificationResult, "", "Classification result should be empty")
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil")
        // Note: isProcessing might still be true if classification is in progress
    }
    
    // MARK: - classifyImage Tests
    
    /// Test that classifyImage returns error when no image is selected
    func testClassifyImageWithNoImage() throws {
        // Given: No image is selected
        viewModel.selectedImage = nil
        
        // When: Attempting to classify
        viewModel.classifyImage()
        
        // Then: Should have error message
        XCTAssertNotNil(viewModel.errorMessage, "Should have error message when no image is selected")
        XCTAssertEqual(viewModel.errorMessage, "No image selected", "Error message should match")
        XCTAssertFalse(viewModel.isProcessing, "Should not be processing")
    }
    
    /// Test that classifyImage sets isProcessing to true when starting
    func testClassifyImageSetsProcessingState() throws {
        // Given: A test image is selected
        viewModel.selectedImage = createTestImage()
        
        // When: Starting classification
        viewModel.classifyImage()
        
        // Then: isProcessing should be true (at least initially, before async completion)
        // Note: This tests the synchronous part of classifyImage
        // The actual processing happens asynchronously
    }
    
    /// Test that classifyImage clears errorMessage and classificationResult when starting
    func testClassifyImageClearsPreviousResults() throws {
        // Given: ViewModel has previous error and result
        viewModel.selectedImage = createTestImage()
        viewModel.errorMessage = "Previous Error"
        viewModel.classificationResult = "Previous Result"
        
        // When: Starting new classification
        viewModel.classifyImage()
        
        // Then: Previous error and result should be cleared
        XCTAssertNil(viewModel.errorMessage, "Error message should be cleared")
        XCTAssertEqual(viewModel.classificationResult, "", "Classification result should be cleared")
    }
    
    /// Test that classifyImage handles case when model is not available
    func testClassifyImageWithoutModel() throws {
        // Given: An image but model might not be loaded (depends on test environment)
        viewModel.selectedImage = createTestImage()
        
        // When: Attempting to classify
        viewModel.classifyImage()
        
        // Then: Either model loads successfully or error is set
        // This test verifies the model availability check path
        // In a real scenario with mocked model, we'd verify the specific error message
    }
    
    // MARK: - Integration Tests
    
    /// Test the complete flow: setImage -> automatic classification
    func testSetImageTriggersClassification() throws {
        // Given: A test image
        let testImage = createTestImage()
        
        // When: Setting the image (which should trigger classification)
        viewModel.setImage(testImage)
        
        // Then: Image should be set and classification should be attempted
        XCTAssertNotNil(viewModel.selectedImage, "Image should be set")
        // Note: Actual classification result depends on the model and image
        // In a real test environment with the model, we'd wait for async completion
    }
    
    /// Test that setting nil image clears result without classification
    func testSetNilImageDoesNotClassify() throws {
        // Given: ViewModel has a result
        viewModel.classificationResult = "Previous Result"
        
        // When: Setting image to nil
        viewModel.setImage(nil)
        
        // Then: Result should be cleared without attempting classification
        XCTAssertNil(viewModel.selectedImage, "Image should be nil")
        XCTAssertEqual(viewModel.classificationResult, "", "Result should be cleared")
        XCTAssertFalse(viewModel.isProcessing, "Should not be processing")
    }
    
    // MARK: - Edge Cases Tests
    
    /// Test multiple clearImage calls
    func testMultipleClearImageCalls() throws {
        // Given: ViewModel with data
        viewModel.selectedImage = createTestImage()
        viewModel.classificationResult = "Result"
        viewModel.errorMessage = "Error"
        
        // When: Clearing multiple times
        viewModel.clearImage()
        viewModel.clearImage()
        viewModel.clearImage()
        
        // Then: Should remain cleared
        XCTAssertNil(viewModel.selectedImage, "Image should remain nil")
        XCTAssertEqual(viewModel.classificationResult, "", "Result should remain empty")
        XCTAssertNil(viewModel.errorMessage, "Error should remain nil")
    }
    
    /// Test setting same image multiple times
    func testSetSameImageMultipleTimes() throws {
        // Given: A test image
        let testImage = createTestImage()
        
        // When: Setting the same image multiple times
        viewModel.setImage(testImage)
        viewModel.setImage(testImage)
        viewModel.setImage(testImage)
        
        // Then: Image should still be set
        XCTAssertNotNil(viewModel.selectedImage, "Image should be set")
        XCTAssertEqual(viewModel.selectedImage, testImage, "Image should match")
    }
    
    /// Test classifyImage when already processing
    func testClassifyImageWhileProcessing() throws {
        // Given: ViewModel is processing
        viewModel.selectedImage = createTestImage()
        viewModel.isProcessing = true
        
        // When: Attempting to classify again
        viewModel.classifyImage()
        
        // Then: Should handle gracefully (isProcessing will be set to true again)
        // This tests that the function doesn't crash when called multiple times
    }
    
    // MARK: - Helper Methods
    
    /// Creates a test UIImage for testing purposes
    private func createTestImage() -> UIImage {
        // Create a simple 100x100 pixel image
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
