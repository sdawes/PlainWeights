//
//  ExerciseDetailViewModel.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 04/09/2025.
//

import Foundation
import SwiftUI
import SwiftData

/// ViewModel for ExerciseDetailView, coordinating between services and managing view state
@Observable
final class ExerciseDetailViewModel {
    
    // MARK: - Properties
    
    let exercise: Exercise
    private let context: ModelContext
    
    // Form state
    var weightText = ""
    var repsText = ""
    var name: String
    
    enum Field {
        case weight, reps
    }
    
    // Computed properties for UI
    var progressState: ProgressTracker.ProgressState?
    var dayGroups: [ExerciseDataGrouper.DayGroup] = []
    
    // MARK: - Initialization
    
    init(exercise: Exercise, context: ModelContext) {
        self.exercise = exercise
        self.context = context
        self.name = exercise.name
    }
    
    // MARK: - Data Updates
    
    /// Update computed properties when sets change
    func updateComputedProperties(with sets: [ExerciseSet]) {
        progressState = ProgressTracker.createProgressState(from: sets)
        dayGroups = ExerciseDataGrouper.createDayGroups(from: sets)
    }
    
    // MARK: - Exercise Operations
    
    /// Add a new set to the exercise
    func addSet() {
        guard let weight = Double(weightText),
              let reps = Int(repsText),
              weight > 0,
              reps > 0 else { return }
        
        let set = ExerciseSet(weight: weight, reps: reps, exercise: exercise)
        context.insert(set)
        
        do {
            try context.save()
            // Clear form fields after successful save
            clearForm()
        } catch {
            // Handle error appropriately
            print("Error saving set: \(error)")
        }
    }
    
    /// Repeat a specific set
    func repeatSet(_ set: ExerciseSet) {
        let newSet = ExerciseSet(
            weight: set.weight,
            reps: set.reps,
            exercise: exercise
        )
        context.insert(newSet)
        
        do {
            try context.save()
        } catch {
            print("Error repeating set: \(error)")
        }
    }
    
    /// Delete a specific set
    func deleteSet(_ set: ExerciseSet) {
        context.delete(set)
        
        do {
            try context.save()
        } catch {
            print("Error deleting set: \(error)")
        }
    }
    
    /// Update exercise name
    func updateExerciseName() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != exercise.name else { return }
        
        exercise.name = trimmed
        exercise.bumpUpdated()
        
        do {
            try context.save()
        } catch {
            print("Error updating exercise name: \(error)")
        }
    }
    
    // MARK: - Form Management
    
    /// Clear form fields
    private func clearForm() {
        weightText = ""
        repsText = ""
    }
    
    /// End editing and update name if needed
    func endEditing() {
        updateExerciseName()
    }
    
    /// Check if add button should be enabled
    var canAddSet: Bool {
        !weightText.isEmpty && !repsText.isEmpty
    }
    
    // MARK: - Convenience Methods
    
    /// Check if a set is the most recent overall
    func isMostRecentSet(_ set: ExerciseSet, in sets: [ExerciseSet]) -> Bool {
        set.persistentModelID == sets.first?.persistentModelID
    }
    
    /// Get formatted day header for a date
    func formattedDayHeader(for date: Date) -> String {
        Formatters.formatAbbreviatedDayHeader(date)
    }
    
    /// Get formatted volume text
    func formattedVolume(_ volume: Double) -> String {
        Formatters.formatVolume(volume)
    }
    
    /// Get formatted weight text
    func formattedWeight(_ weight: Double) -> String {
        Formatters.formatWeight(weight)
    }
}