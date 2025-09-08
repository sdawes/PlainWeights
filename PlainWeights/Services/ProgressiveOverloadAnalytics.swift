//
//  ProgressiveOverloadAnalytics.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 08/09/2025.
//

import Foundation

/// Service for calculating progressive overload targets and analyzing progression patterns
enum ProgressiveOverloadAnalytics {
    
    // MARK: - Progressive Overload Analysis
    
    /// Calculate progression targets with data validation
    static func calculateProgressionTargets(from sets: [ExerciseSet]) -> ProgressionResult {
        let baselineResult = SessionValidator.findReliableBaselineSession(from: sets)
        
        switch baselineResult {
        case .none:
            return .insufficientData(message: "Baseline day")
            
        case .reliable(let baselineSets, _):
            guard let targets = generateProgressionTargets(from: baselineSets) else {
                return .insufficientData(message: "Unable to calculate progression")
            }
            return .valid(targets: targets)
            
        case .unreliable(let baselineSets, _, let warning):
            guard let targets = generateProgressionTargets(from: baselineSets) else {
                return .unreliableData(warning: warning, targets: nil)
            }
            return .unreliableData(warning: warning, targets: targets)
        }
    }
    
    /// Generate specific progression targets from a baseline session
    private static func generateProgressionTargets(from baselineSets: [ExerciseSet]) -> ProgressionTargets? {
        guard !baselineSets.isEmpty else { return nil }
        
        // Sort sets by timestamp to get chronological order
        let chronologicalSets = baselineSets.sorted { $0.timestamp < $1.timestamp }
        
        // Find the weight used most frequently (primary working weight)
        let weightFrequency = Dictionary(grouping: chronologicalSets) { $0.weight }
        let primaryWeight = weightFrequency.max { $0.value.count < $1.value.count }?.key ?? chronologicalSets.first!.weight
        
        // Get sets at primary weight to analyze rep pattern
        let primaryWeightSets = chronologicalSets.filter { $0.weight == primaryWeight }
        let repPattern = primaryWeightSets.map { $0.reps }
        
        // Calculate progression paths
        let repProgression = calculateRepProgression(weight: primaryWeight, reps: repPattern)
        let weightProgression = calculateWeightProgression(weight: primaryWeight, reps: repPattern)
        
        // Determine recommended path based on rep ranges
        let recommendedPath = determineRecommendedPath(repPattern: repPattern)
        
        return ProgressionTargets(
            lastSession: SessionSummary(
                sets: chronologicalSets.count,
                primaryWeight: primaryWeight,
                repPattern: repPattern
            ),
            repProgression: repProgression,
            weightProgression: weightProgression,
            recommendedPath: recommendedPath
        )
    }
    
    /// Calculate rep progression target
    private static func calculateRepProgression(weight: Double, reps: [Int]) -> RepProgression {
        let totalReps = reps.reduce(0, +)
        let targetIncrease = reps.count <= 3 ? 2 : 1 // More conservative for higher volume
        
        var targetReps = reps
        // Add reps to the set that can handle it best (usually first/strongest set)
        if let firstIndex = targetReps.indices.first {
            targetReps[firstIndex] += min(targetIncrease, 2)
        }
        // Distribute remaining increases
        var remainingIncrease = targetIncrease - min(targetIncrease, 2)
        for i in 1..<targetReps.count {
            if remainingIncrease > 0 {
                targetReps[i] += 1
                remainingIncrease -= 1
            }
        }
        
        return RepProgression(
            weight: weight,
            targetReps: targetReps,
            totalRepsGain: targetReps.reduce(0, +) - totalReps
        )
    }
    
    /// Calculate weight progression target
    private static func calculateWeightProgression(weight: Double, reps: [Int]) -> WeightProgression {
        // Standard progression: +2.5kg for most exercises
        let weightIncrease: Double = 2.5
        let newWeight = weight + weightIncrease
        
        // Keep same rep pattern for weight progression
        return WeightProgression(
            weight: newWeight,
            targetReps: reps,
            weightIncrease: weightIncrease
        )
    }
    
    /// Determine recommended progression path based on rep patterns
    private static func determineRecommendedPath(repPattern: [Int]) -> ProgressionPath {
        let averageReps = Double(repPattern.reduce(0, +)) / Double(repPattern.count)
        
        // Low reps (strength range) - prioritize reps
        if averageReps < 6 {
            return .reps
        }
        // High reps (endurance range) - prioritize weight
        else if averageReps > 12 {
            return .weight
        }
        // Hypertrophy range - balanced approach, slight preference for reps
        else {
            return .reps
        }
    }
}

// MARK: - Supporting Types

/// Result of progression analysis
enum ProgressionResult {
    case valid(targets: ProgressionTargets)
    case insufficientData(message: String)
    case unreliableData(warning: String, targets: ProgressionTargets?)
    
    var targets: ProgressionTargets? {
        switch self {
        case .valid(let targets), .unreliableData(_, let targets):
            return targets
        case .insufficientData:
            return nil
        }
    }
    
    var hasWarning: Bool {
        switch self {
        case .unreliableData: return true
        case .valid, .insufficientData: return false
        }
    }
    
    var warning: String? {
        switch self {
        case .unreliableData(let warning, _): return warning
        case .valid, .insufficientData: return nil
        }
    }
}

/// Complete progression targets for a session
struct ProgressionTargets {
    let lastSession: SessionSummary
    let repProgression: RepProgression
    let weightProgression: WeightProgression
    let recommendedPath: ProgressionPath
}

/// Summary of last completed session
struct SessionSummary {
    let sets: Int
    let primaryWeight: Double
    let repPattern: [Int]
    
    var description: String {
        let repsString = repPattern.map(String.init).joined(separator: ", ")
        return "\(sets) sets × \(Formatters.formatWeight(primaryWeight)) kg (\(repsString) reps)"
    }
}

/// Rep-based progression target
struct RepProgression {
    let weight: Double
    let targetReps: [Int]
    let totalRepsGain: Int
    
    var description: String {
        let repsString = targetReps.map(String.init).joined(separator: ", ")
        return "\(Formatters.formatWeight(weight)) kg (\(repsString) reps)"
    }
}

/// Weight-based progression target  
struct WeightProgression {
    let weight: Double
    let targetReps: [Int]
    let weightIncrease: Double
    
    var description: String {
        let repsString = targetReps.map(String.init).joined(separator: ", ")
        return "\(Formatters.formatWeight(weight)) kg (\(repsString) reps)"
    }
}

/// Recommended progression strategy
enum ProgressionPath {
    case reps    /// Focus on adding repetitions
    case weight  /// Focus on adding weight
    case balanced /// Equal focus on both
    
    var description: String {
        switch self {
        case .reps: return "Add reps"
        case .weight: return "Add weight"
        case .balanced: return "Balanced"
        }
    }
}