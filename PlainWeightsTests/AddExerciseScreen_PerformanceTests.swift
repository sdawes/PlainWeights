//
//  AddExerciseScreen_PerformanceTests.swift
//  PlainWeightsTests
//
//  Performance tests for the Add Exercise screen functionality
//

import XCTest
import SwiftUI
@testable import PlainWeights

final class AddExerciseScreen_PerformanceTests: XCTestCase {
    
    // Test how quickly the Add Exercise view loads
    func testLoadingAddExerciseView() throws {
        measure {
            let _ = AddExerciseView()
        }
    }
    
    // Test performance of entering exercise name
    func testEnteringExerciseName() throws {
        measure {
            let textField = UITextField()
            textField.placeholder = "Exercise Name"
            textField.becomeFirstResponder()
            
            // Simulate typing exercise name
            textField.text = "Bench Press"
            textField.sendActions(for: .editingChanged)
        }
    }
}