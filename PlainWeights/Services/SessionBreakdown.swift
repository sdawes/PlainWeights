//
//  SessionBreakdown.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 08/09/2025.
//

import Foundation

/// Simple service for breaking down last session sets by weight for display
enum SessionBreakdown {
    
    /// Get last session sets grouped by weight with rep patterns
    static func getLastSessionBreakdown(from sets: [ExerciseSet]) -> [WeightGroup]? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Group sets by day
        let setsByDay = Dictionary(grouping: sets) { set in
            calendar.startOfDay(for: set.timestamp)
        }
        
        // Find the most recent day before today with sets
        let pastDays = setsByDay.keys.filter { $0 < today }.sorted(by: >)
        
        guard let lastDay = pastDays.first,
              let lastDaySets = setsByDay[lastDay] else {
            return nil
        }
        
        // Sort sets by timestamp to maintain chronological order
        let chronologicalSets = lastDaySets.sorted { $0.timestamp < $1.timestamp }
        
        // Group sets by weight, preserving order of first appearance
        let weightGroups = Dictionary(grouping: chronologicalSets) { $0.weight }
        
        // Create weight groups sorted by the order they first appeared in the session
        var seenWeights: [Double] = []
        var orderedGroups: [WeightGroup] = []
        
        for set in chronologicalSets {
            if !seenWeights.contains(set.weight) {
                seenWeights.append(set.weight)
                let setsAtWeight = weightGroups[set.weight] ?? []
                let reps = setsAtWeight.map { $0.reps }
                orderedGroups.append(WeightGroup(weight: set.weight, reps: reps))
            }
        }
        
        return orderedGroups
    }
}

// MARK: - Supporting Types

/// A group of sets at the same weight
struct WeightGroup {
    let weight: Double
    let reps: [Int]
    
    var description: String {
        let repsString = reps.map(String.init).joined(separator: ", ")
        let setCount = reps.count
        
        if setCount == 1 {
            return "1 set × \(Formatters.formatWeight(weight)) kg (\(repsString) reps)"
        } else {
            return "\(setCount) sets × \(Formatters.formatWeight(weight)) kg (\(repsString) reps)"
        }
    }
}