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
        let lastCompletedDayInfo: (date: Date, volume: Double, maxWeight: Double)?
        let progressRatioUnclamped: Double
        let progressBarRatio: Double
        let percentOfLast: Int
        let gainsPercent: Int
        let showProgressBar: Bool
        let barFillColor: Color
        let gainsColor: Color
        let deltaText: String
        
        init(from sets: [ExerciseSet]) {
            // Calculate core metrics using VolumeAnalytics
            self.todayVolume = VolumeAnalytics.todayVolume(from: sets)
            self.lastCompletedDayInfo = VolumeAnalytics.lastCompletedDayInfo(from: sets)
            
            let lastVolume = lastCompletedDayInfo?.volume
            
            self.progressRatioUnclamped = VolumeAnalytics.progressRatioUnclamped(
                todayVolume: todayVolume, 
                lastCompletedVolume: lastVolume
            )
            
            self.progressBarRatio = VolumeAnalytics.progressBarRatio(
                todayVolume: todayVolume, 
                lastCompletedVolume: lastVolume
            )
            
            self.percentOfLast = VolumeAnalytics.percentOfLast(
                todayVolume: todayVolume, 
                lastCompletedVolume: lastVolume
            )
            
            self.gainsPercent = VolumeAnalytics.gainsPercent(
                todayVolume: todayVolume, 
                lastCompletedVolume: lastVolume
            )
            
            self.showProgressBar = VolumeAnalytics.shouldShowProgressBar(
                lastCompletedVolume: lastVolume
            )
            
            // Determine colors
            self.barFillColor = ProgressTracker.barFillColor(percentOfLast: percentOfLast)
            self.gainsColor = ProgressTracker.gainsColor(gainsPercent: gainsPercent)
            
            // Format delta text
            self.deltaText = Formatters.formatDeltaText(
                todayVolume: todayVolume, 
                lastCompletedDayInfo: lastCompletedDayInfo
            )
        }
    }
    
    // MARK: - Convenience Methods
    
    /// Create progress state for given exercise sets
    static func createProgressState(from sets: [ExerciseSet]) -> ProgressState {
        ProgressState(from: sets)
    }
}