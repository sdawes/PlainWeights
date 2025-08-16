//
//  PlainWeightsTests.swift
//  PlainWeightsTests
//
//  Created by Stephen Dawes on 16/08/2025.
//

import XCTest
import SwiftUI
@testable import PlainWeights

final class PlainWeightsTests: XCTestCase {

    func testAddExerciseViewRenderingPerformance() throws {
        measure {
            let _ = AddExerciseView()
        }
    }
    
    func testTextFieldInteractionPerformance() throws {
        // Performance test for text field creation and setup
        // This gives us a baseline for how quickly text input can be prepared
        measure {
            // Create a text field and simulate focus preparation
            let textField = UITextField()
            textField.placeholder = "Exercise Name"
            textField.becomeFirstResponder()
        }
    }

}
