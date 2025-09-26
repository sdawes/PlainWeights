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
        if gainsPercent < 0 { return .red }
        return .secondary
    }
    
    // MARK: - Progress State
    
    /// Complete progress state for a workout session
    struct ProgressState {
        let todayVolume: Double
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

        init(from sets: [ExerciseSet]) {
            // Get today's and last session metrics
            let todayMetrics = ExerciseSessionMetrics.getTodaySessionMetrics(from: sets)
            let lastMetrics = ExerciseSessionMetrics.getLastSessionMetrics(from: sets)

            self.todayVolume = todayMetrics?.value ?? 0

            // Set display labels based on today's exercise type
            if let todayMetrics = todayMetrics {
                self.progressLabel = ExerciseVolumeCalculator.getProgressLabel(for: todayMetrics.type)
                self.unit = ExerciseVolumeCalculator.getUnit(for: todayMetrics.type)
            } else {
                self.progressLabel = "Lifted today"
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
                today: todayMetrics ?? SessionMetrics(type: .weightBased, value: 0, maxWeight: 0, maxWeightReps: 0, totalSets: 0, date: Date()),
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
                    self.deltaText = "Exercise type changed"
                } else {
                    self.deltaText = ""
                }
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