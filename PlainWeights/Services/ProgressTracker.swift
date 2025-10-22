//
//  ProgressTracker.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 04/09/2025.
//

import Foundation
import SwiftUI

/// Service for tracking progress and determining UI presentation colors/states
enum ProgressTracker {
    
    // MARK: - Color Logic
    
    /// Determine the fill color for progress bar based on achievement percentage
    static func barFillColor(percentOfLast: Int) -> Color {
        percentOfLast >= 100 ? .green : .accentColor
    }
    
    /// Determine color for gains display based on performance
    static func gainsColor(gainsPercent: Int) -> Color {
        if gainsPercent > 0 { return .green }
        if gainsPercent < 0 { return Color(red: 0.7, green: 0.1, blue: 0.1) }
        return .secondary
    }

    /// Determine direction and color for volume/reps comparison
    /// - Parameters:
    ///   - today: Today's volume or rep count
    ///   - last: Last session's volume or rep count
    /// - Returns: PRDirection indicating performance (up/same/down)
    static func volumeComparisonDirection(today: Double, last: Double) -> PRDirection {
        if today > last { return .up }
        if today < last { return .down }
        return .same
    }

    // MARK: - Personal Record Indicators

    enum PRDirection {
        case up, down, same

        var iconName: String {
            switch self {
            case .up: return "arrow.up.circle.fill"
            case .down: return "arrow.down.circle.fill"
            case .same: return "minus.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .up: return .green                                  // Green for improvements
            case .down: return Color(red: 0.7, green: 0.1, blue: 0.1)  // Darker red for decreases
            case .same: return .blue                                 // Blue for no change
            }
        }
    }

    struct PersonalRecordIndicators {
        let weightImprovement: Double
        let repsImprovement: Int
        let weightDirection: PRDirection
        let repsDirection: PRDirection
        let hasWeightPR: Bool
        let hasRepsPR: Bool
        let exerciseType: ExerciseMetricsType

        static func compare(todaysNewestWeight: Double, todaysNewestReps: Int,
                          lastSessionMaxWeight: Double, lastSessionMaxReps: Int,
                          exerciseType: ExerciseMetricsType) -> PersonalRecordIndicators {

            let weightDiff = todaysNewestWeight - lastSessionMaxWeight
            let repsDiff = todaysNewestReps - lastSessionMaxReps

            let weightDirection: PRDirection
            let repsDirection: PRDirection

            if weightDiff > 0 {
                weightDirection = .up
            } else if weightDiff < 0 {
                weightDirection = .down
            } else {
                weightDirection = .same
            }

            if repsDiff > 0 {
                repsDirection = .up
            } else if repsDiff < 0 {
                repsDirection = .down
            } else {
                repsDirection = .same
            }

            return PersonalRecordIndicators(
                weightImprovement: weightDiff,
                repsImprovement: repsDiff,
                weightDirection: weightDirection,
                repsDirection: repsDirection,
                hasWeightPR: weightDirection == .up,
                hasRepsPR: repsDirection == .up,
                exerciseType: exerciseType
            )
        }
    }

    // MARK: - Progress State

    /// Complete progress state for a workout session
    struct ProgressState {
        let todayVolume: Double
        let todayWeightVolume: Double  // Weight-only volume for display
        let lastCompletedDayInfo: (date: Date, volume: Double, maxWeight: Double, maxWeightReps: Int)?
        let progressRatioUnclamped: Double
        let progressBarRatio: Double
        let percentOfLast: Int
        let gainsPercent: Int
        let showProgressBar: Bool
        let barFillColor: Color
        let gainsColor: Color
        let deltaText: String
        let progressLabel: String
        let unit: String
        let canCompareToLast: Bool
        let personalRecords: PersonalRecordIndicators?

        init(from sets: [ExerciseSet]) {
            // Get today's and last session metrics
            let todayMetrics = ExerciseSessionMetrics.getTodaySessionMetrics(from: sets)
            let lastMetrics = ExerciseSessionMetrics.getLastSessionMetrics(from: sets)

            self.todayVolume = todayMetrics?.value ?? 0

            // Calculate weight-only volume for display (shows 0 kg for reps-only exercises)
            let todaysSets = ExerciseSessionMetrics.getTodaysSets(from: sets)
            self.todayWeightVolume = ExerciseVolumeCalculator.calculateWeightVolume(for: todaysSets)

            // Set display labels - always show comparison label (matches header above)
            self.progressLabel = "Set vs max last"
            if let todayMetrics = todayMetrics {
                self.unit = ExerciseVolumeCalculator.getUnit(for: todayMetrics.type)
            } else {
                self.unit = "kg"
            }

            // Build lastCompletedDayInfo for backward compatibility
            if let lastMetrics = lastMetrics {
                self.lastCompletedDayInfo = (
                    date: lastMetrics.date,
                    volume: lastMetrics.value,
                    maxWeight: lastMetrics.maxWeight,
                    maxWeightReps: lastMetrics.maxWeightReps
                )
            } else {
                self.lastCompletedDayInfo = nil
            }

            // Calculate progress with type comparison
            let progressResult = ExerciseVolumeCalculator.calculateProgress(
                today: todayMetrics ?? SessionMetrics(type: .combined, value: 0, maxWeight: 0, maxWeightReps: 0, totalSets: 0, date: Date()),
                last: lastMetrics
            )

            self.canCompareToLast = progressResult.canCompare

            if progressResult.canCompare {
                self.percentOfLast = progressResult.percentage
                self.showProgressBar = true

                let lastVolume = lastCompletedDayInfo?.volume

                self.progressRatioUnclamped = VolumeAnalytics.progressRatioUnclamped(
                    todayVolume: todayVolume,
                    lastCompletedVolume: lastVolume
                )

                self.progressBarRatio = VolumeAnalytics.progressBarRatio(
                    todayVolume: todayVolume,
                    lastCompletedVolume: lastVolume
                )

                self.gainsPercent = VolumeAnalytics.gainsPercent(
                    todayVolume: todayVolume,
                    lastCompletedVolume: lastVolume
                )

                self.deltaText = Formatters.formatDeltaText(
                    todayVolume: todayVolume,
                    lastCompletedDayInfo: lastCompletedDayInfo
                )
            } else {
                // Can't compare - different exercise types or no history
                // Calculate percentage for new exercises using 0-baseline math
                self.percentOfLast = VolumeAnalytics.percentOfLast(
                    todayVolume: todayVolume,
                    lastCompletedVolume: lastCompletedDayInfo?.volume
                )
                self.showProgressBar = true  // Always show progress bar

                // Use our updated analytics for consistent calculations
                let lastVolume = lastCompletedDayInfo?.volume
                self.progressRatioUnclamped = VolumeAnalytics.progressRatioUnclamped(
                    todayVolume: todayVolume,
                    lastCompletedVolume: lastVolume
                )
                self.progressBarRatio = VolumeAnalytics.progressBarRatio(
                    todayVolume: todayVolume,
                    lastCompletedVolume: lastVolume
                )
                self.gainsPercent = VolumeAnalytics.gainsPercent(
                    todayVolume: todayVolume,
                    lastCompletedVolume: lastVolume
                )

                if lastMetrics != nil && !progressResult.canCompare {
                    // Only show "type changed" if it's a real type change, not data inconsistency
                    // For new exercises or consistent reps-only, show nothing
                    if let todayMetrics = todayMetrics, let lastMetrics = lastMetrics {
                        // Check if this is a legitimate type change vs data inconsistency
                        let todayHasWeight = todayMetrics.value > 0 && (todayMetrics.type == .weightOnly || todayMetrics.type == .combined)
                        let lastHadWeight = lastMetrics.value > 0 && (lastMetrics.type == .weightOnly || lastMetrics.type == .combined)

                        if todayHasWeight != lastHadWeight {
                            self.deltaText = "Exercise type changed"
                        } else {
                            self.deltaText = ""
                        }
                    } else {
                        self.deltaText = ""
                    }
                } else {
                    self.deltaText = ""
                }
            }

            // Calculate personal records by comparing today's newest set with last session's max
            // If no history exists, compare against 0/0 baseline to show absolute improvement
            if let newestSet = ExerciseSessionMetrics.getTodaysMostRecentSet(from: sets) {
                let lastMaxWeight = lastMetrics?.maxWeight ?? 0.0
                let lastMaxReps = lastMetrics?.maxWeightReps ?? 0

                // Detect exercise type for adaptive indicators
                let exerciseType = ExerciseMetricsType.determine(from: sets)

                self.personalRecords = PersonalRecordIndicators.compare(
                    todaysNewestWeight: newestSet.weight,
                    todaysNewestReps: newestSet.reps,
                    lastSessionMaxWeight: lastMaxWeight,
                    lastSessionMaxReps: lastMaxReps,
                    exerciseType: exerciseType
                )
            } else {
                self.personalRecords = nil
            }

            // Determine colors
            self.barFillColor = ProgressTracker.barFillColor(percentOfLast: percentOfLast)
            self.gainsColor = ProgressTracker.gainsColor(gainsPercent: gainsPercent)
        }
    }
    
    // MARK: - Convenience Methods
    
    /// Create progress state for given exercise sets
    static func createProgressState(from sets: [ExerciseSet]) -> ProgressState {
        ProgressState(from: sets)
    }
}