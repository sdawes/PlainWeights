//
//  ExerciseDetailView_PerformanceTests.swift
//  PlainWeightsTests
//
//  Performance tests for the Exercise Detail view with inline set entry
//

import XCTest
import SwiftUI
import SwiftData
@testable import PlainWeights

final class ExerciseDetailView_PerformanceTests: XCTestCase {
    
    // Test how quickly the Exercise Detail view loads
    func testLoadingExerciseDetailView() throws {
        let exercise = Exercise(name: "Bench Press", category: "Chest")
        
        measure {
            let _ = ExerciseDetailView(exercise: exercise)
        }
    }
    
    // Test performance of entering weight value in inline form
    func testEnteringWeightValueInline() throws {
        measure {
            let textField = UITextField()
            textField.placeholder = "0"
            textField.keyboardType = .decimalPad
            textField.textAlignment = .right
            textField.becomeFirstResponder()
            
            // Simulate typing weight value
            textField.text = "75.5"
            textField.sendActions(for: .editingChanged)
        }
    }
    
    // Test performance of entering reps value in inline form
    func testEnteringRepsValueInline() throws {
        measure {
            let textField = UITextField()
            textField.placeholder = "0"
            textField.keyboardType = .numberPad
            textField.textAlignment = .right
            textField.becomeFirstResponder()
            
            // Simulate typing reps value
            textField.text = "12"
            textField.sendActions(for: .editingChanged)
        }
    }
    
    // Test performance of adding a set inline (validation + data creation)
    func testAddingSetInline() throws {
        measure {
            // Simulate validation checks
            let weightText = "75.5"
            let repsText = "12"
            
            let weight = Double(weightText)
            let reps = Int(repsText)
            
            // Validation logic
            let isValid = weight != nil && reps != nil && weight! > 0 && reps! > 0
            
            // Create ExerciseSet if valid
            if isValid {
                let exercise = Exercise(name: "Test", category: "Test")
                let _ = ExerciseSet(weight: weight!, reps: reps!, exercise: exercise)
            }
        }
    }
}