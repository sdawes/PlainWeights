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

    private(set) static var currentActivity: Activity<RestTimerAttributes>?

    static func startTimer(exerciseName: String, startTime: Date) {
        stopTimer()

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
            print("[RestTimer] Failed to start Live Activity: \(error)")
        }
    }

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
