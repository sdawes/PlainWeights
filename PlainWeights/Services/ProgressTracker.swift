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

    /// Determine the fill color for progress bar (uses primary color for black/white theme)
    static func barFillColor(percentOfLast: Int) -> Color {
        .primary
    }

    /// Determine color for gains display (uses primary color for black/white theme)
    static func gainsColor(gainsPercent: Int) -> Color {
        .primary
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

    // MARK: - Progress Indicators

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
            .primary  // Black/white theme uses primary color
        }

        /// Colored version for progress delta display (green/red/blue)
        var progressColor: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .same: return .blue
            }
        }
    }

    // MARK: - Last Mode Indicators (Today vs Last Session)

    struct LastModeIndicators {
        let weightImprovement: Double
        let repsImprovement: Int
        let volumeImprovement: Double
        let weightDirection: PRDirection
        let repsDirection: PRDirection
        let volumeDirection: PRDirection
        let hasWeightPR: Bool
        let hasRepsPR: Bool
        let hasVolumePR: Bool
        let exerciseType: ExerciseMetricsType

        static func compare(todaysMaxWeight: Double, todaysMaxReps: Int, todaysVolume: Double,
                          lastSessionMaxWeight: Double, lastSessionMaxReps: Int, lastSessionVolume: Double,
                          exerciseType: ExerciseMetricsType) -> LastModeIndicators {

            let weightDiff = todaysMaxWeight - lastSessionMaxWeight
            let repsDiff = todaysMaxReps - lastSessionMaxReps
            let volumeDiff = todaysVolume - lastSessionVolume

            let weightDirection: PRDirection
            let repsDirection: PRDirection
            let volumeDirection: PRDirection

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

            if volumeDiff > 0 {
                volumeDirection = .up
            } else if volumeDiff < 0 {
                volumeDirection = .down
            } else {
                volumeDirection = .same
            }

            return LastModeIndicators(
                weightImprovement: weightDiff,
                repsImprovement: repsDiff,
                volumeImprovement: volumeDiff,
                weightDirection: weightDirection,
                repsDirection: repsDirection,
                volumeDirection: volumeDirection,
                hasWeightPR: weightDirection == .up,
                hasRepsPR: repsDirection == .up,
                hasVolumePR: volumeDirection == .up,
                exerciseType: exerciseType
            )
        }
    }

    // MARK: - Best Mode Indicators (Today vs All-Time Best)

    struct BestModeIndicators {
        let weightImprovement: Double
        let repsImprovement: Int
        let volumeImprovement: Double
        let weightDirection: PRDirection
        let repsDirection: PRDirection
        let volumeDirection: PRDirection
        let hasNewWeightPR: Bool
        let hasNewRepsPR: Bool
        let hasNewVolumePR: Bool

        static func calculate(
            todaySets: [ExerciseSet],
            bestMetrics: BestSessionCalculator.BestDayMetrics?
        ) -> BestModeIndicators? {
            // Return nil when no sets added today (matches Last mode behavior)
            guard !todaySets.isEmpty else { return nil }

            // Get today's best metrics
            let todaysMaxWeight = TodaySessionCalculator.getTodaysMaxWeight(from: todaySets)
            let todaysMaxReps = TodaySessionCalculator.getTodaysMaxReps(from: todaySets)
            let todaysVolume = TodaySessionCalculator.getTodaysVolume(from: todaySets)

            // Get all-time best (or 0 if none)
            let bestWeight = bestMetrics?.maxWeight ?? 0.0
            let bestReps = bestMetrics?.repsAtMaxWeight ?? 0
            let bestVolume = bestMetrics?.totalVolume ?? 0.0

            // Calculate differences
            let weightDiff = todaysMaxWeight - bestWeight
            let repsDiff = todaysMaxReps - bestReps
            let volumeDiff = todaysVolume - bestVolume

            // Determine directions
            let weightDirection: PRDirection = weightDiff > 0 ? .up : (weightDiff < 0 ? .down : .same)
            let repsDirection: PRDirection = repsDiff > 0 ? .up : (repsDiff < 0 ? .down : .same)
            let volumeDirection: PRDirection = volumeDiff > 0 ? .up : (volumeDiff < 0 ? .down : .same)

            return BestModeIndicators(
                weightImprovement: weightDiff,
                repsImprovement: repsDiff,
                volumeImprovement: volumeDiff,
                weightDirection: weightDirection,
                repsDirection: repsDirection,
                volumeDirection: volumeDirection,
                hasNewWeightPR: weightDirection == .up,
                hasNewRepsPR: repsDirection == .up,
                hasNewVolumePR: volumeDirection == .up
            )
        }
    }

    // MARK: - Progress State

    /// Complete progress state for a workout session
    struct ProgressState {
        let todayVolume: Double
        let todayWeightVolume: Double  // Weight-only volume for display
        let lastCompletedDayInfo: (date: Date, volume: Double, maxWeight: Double, maxWeightReps: Int, isDropSet: Bool, isPauseAtTop: Bool, isTimedSet: Bool, tempoSeconds: Int, isPB: Bool)?
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
        let personalRecords: LastModeIndicators?

        init(from sets: [ExerciseSet]) {
            // Get today's and last session metrics
            let todayMetrics = TodaySessionCalculator.getTodaySessionMetrics(from: sets)
            let lastMetrics = LastSessionCalculator.getLastSessionMetrics(from: sets)

            self.todayVolume = todayMetrics?.value ?? 0

            // Calculate weight-only volume for display (shows 0 kg for reps-only exercises)
            let todaysSets = TodaySessionCalculator.getTodaysSets(from: sets)
            self.todayWeightVolume = ExerciseVolumeCalculator.calculateWeightVolume(for: todaysSets)

            // Set display labels - always show comparison label (matches header above)
            self.progressLabel = "Set vs max last"
            if let todayMetrics = todayMetrics {
                self.unit = ExerciseVolumeCalculator.getUnit(for: todayMetrics.type)
            } else {
                self.unit = "kg"
            }

            // Build lastCompletedDayInfo with set flags from ExerciseDataHelper
            if let lastDayInfo = ExerciseDataHelper.getLastCompletedDayInfo(from: sets) {
                self.lastCompletedDayInfo = (
                    date: lastDayInfo.date,
                    volume: lastDayInfo.volume,
                    maxWeight: lastDayInfo.maxWeight,
                    maxWeightReps: lastDayInfo.maxWeightReps,
                    isDropSet: lastDayInfo.isDropSet,
                    isPauseAtTop: lastDayInfo.isPauseAtTop,
                    isTimedSet: lastDayInfo.isTimedSet,
                    tempoSeconds: lastDayInfo.tempoSeconds,
                    isPB: lastDayInfo.isPB
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
            if let newestSet = TodaySessionCalculator.getTodaysMostRecentSet(from: sets) {
                let lastMaxWeight = lastMetrics?.maxWeight ?? 0.0
                let lastMaxReps = lastMetrics?.maxWeightReps ?? 0
                let lastVolume = lastCompletedDayInfo?.volume ?? 0.0

                // Detect exercise type for adaptive indicators
                let exerciseType = ExerciseMetricsType.determine(from: sets)

                self.personalRecords = LastModeIndicators.compare(
                    todaysMaxWeight: newestSet.weight,
                    todaysMaxReps: newestSet.reps,
                    todaysVolume: todayVolume,
                    lastSessionMaxWeight: lastMaxWeight,
                    lastSessionMaxReps: lastMaxReps,
                    lastSessionVolume: lastVolume,
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

    /// Calculate best mode indicators (convenience wrapper)
    static func calculateBestModeIndicators(
        todaySets: [ExerciseSet],
        bestMetrics: BestSessionCalculator.BestDayMetrics?
    ) -> BestModeIndicators? {
        return BestModeIndicators.calculate(todaySets: todaySets, bestMetrics: bestMetrics)
    }
}