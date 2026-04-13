//
//  RestTimerActivityManager.swift
//  PlainWeights
//
//  Manages the Live Activity for rest timer display in Dynamic Island
//  and Lock Screen. Starts when a set is added, stops when rest is captured.
//

import ActivityKit
import Foundation

@MainActor
enum RestTimerActivityManager {

    /// The currently running Live Activity, if any
    private(set) static var currentActivity: Activity<RestTimerAttributes>?

    /// Start a rest timer Live Activity
    static func startTimer(exerciseName: String, startTime: Date) {
        // End any existing timer first
        stopTimer()

        // Check if Live Activities are available
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = RestTimerAttributes(
            exerciseName: exerciseName,
            startTime: startTime,
            maxDuration: 180
        )

        let state = RestTimerAttributes.ContentState(timerRunning: true)

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: startTime.addingTimeInterval(180)),
                pushType: nil
            )
            currentActivity = activity
        } catch {
            // Silently fail — Live Activities are a nice-to-have, not critical
        }
    }

    /// Stop the current rest timer Live Activity
    static func stopTimer() {
        guard let activity = currentActivity else { return }

        let finalState = RestTimerAttributes.ContentState(timerRunning: false)

        Task {
            await activity.end(
                ActivityContent(state: finalState, staleDate: nil),
                dismissalPolicy: .immediate
            )
        }

        currentActivity = nil
    }
}
