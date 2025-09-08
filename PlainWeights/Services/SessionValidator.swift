//
//  SessionValidator.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 08/09/2025.
//

import Foundation

/// Service for validating session data quality and detecting incomplete/unreliable workout sessions
enum SessionValidator {
    
    // MARK: - Session Quality Assessment
    
    /// Analyze session quality to determine if it's suitable for progression analysis
    static func assessSessionQuality(_ sets: [ExerciseSet]) -> SessionQuality {
        guard !sets.isEmpty else { return .insufficient }
        
        // Too few sets for meaningful progression analysis
        if sets.count < 2 {
            return .insufficient
        }
        
        // Check for suspicious patterns that might indicate deleted sets
        let weights = sets.map { $0.weight }
        let uniqueWeights = Set(weights)
        
        // Single set at each weight might indicate missing sets
        if uniqueWeights.count == sets.count && sets.count < 4 {
            return .incomplete
        }
        
        // Check for large gaps in reps that might indicate deletions
        let reps = sets.map { $0.reps }
        let sortedReps = reps.sorted(by: >)
        
        for i in 0..<(sortedReps.count - 1) {
            let repDifference = sortedReps[i] - sortedReps[i + 1]
            // Large rep drops might indicate missing intermediate sets
            if repDifference > 4 {
                return .incomplete
            }
        }
        
        return .complete
    }
    
    /// Find the most reliable recent session for progression baseline
    static func findReliableBaselineSession(from sets: [ExerciseSet]) -> BaselineResult {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Group sets by day
        let setsByDay = Dictionary(grouping: sets) { set in
            calendar.startOfDay(for: set.timestamp)
        }
        
        // Get past days sorted by most recent first
        let pastDays = setsByDay.keys
            .filter { $0 < today }
            .sorted(by: >)
        
        // Try to find a reliable session, starting with most recent
        for day in pastDays {
            guard let daySets = setsByDay[day] else { continue }
            
            let quality = assessSessionQuality(daySets)
            
            switch quality {
            case .complete:
                return .reliable(sets: daySets, quality: .complete)
            case .incomplete:
                // Continue searching, but keep this as fallback
                continue
            case .insufficient:
                continue
            }
        }
        
        // If no complete session found, try to use the most recent incomplete one
        if let mostRecentDay = pastDays.first,
           let mostRecentSets = setsByDay[mostRecentDay] {
            let quality = assessSessionQuality(mostRecentSets)
            if quality != .insufficient {
                return .unreliable(sets: mostRecentSets, quality: quality, warning: "Last session data may be incomplete")
            }
        }
        
        return .none
    }
}

// MARK: - Supporting Types

/// Quality assessment of a workout session
enum SessionQuality {
    case complete      /// Normal session pattern, suitable for progression analysis
    case incomplete    /// Suspicious patterns that might indicate deleted sets
    case insufficient  /// Too few sets for meaningful analysis
    
    var description: String {
        switch self {
        case .complete: return "Complete session"
        case .incomplete: return "Potentially incomplete session"
        case .insufficient: return "Insufficient data for analysis"
        }
    }
}

/// Result of baseline session search
enum BaselineResult {
    case reliable(sets: [ExerciseSet], quality: SessionQuality)
    case unreliable(sets: [ExerciseSet], quality: SessionQuality, warning: String)
    case none
    
    var sets: [ExerciseSet]? {
        switch self {
        case .reliable(let sets, _), .unreliable(let sets, _, _):
            return sets
        case .none:
            return nil
        }
    }
    
    var isReliable: Bool {
        switch self {
        case .reliable: return true
        case .unreliable, .none: return false
        }
    }
    
    var warning: String? {
        switch self {
        case .unreliable(_, _, let warning): return warning
        case .reliable, .none: return nil
        }
    }
}