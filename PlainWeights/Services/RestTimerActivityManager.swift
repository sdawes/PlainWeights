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

    private static var phaseUpdateTask: Task<Void, Never>?

    static func startTimer(exerciseName: String, startTime: Date) {
        stopTimer()

        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = RestTimerAttributes(
            exerciseName: exerciseName,
            startTime: startTime,
            maxDuration: 180
        )

        let state = RestTimerAttributes.ContentState(timerRunning: true, phase: .normal)
        let staleDate = startTime.addingTimeInterval(180)

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: staleDate),
                pushType: nil
            )
            currentActivity = activity
            schedulePhaseUpdates(startTime: startTime, staleDate: staleDate)
        } catch {
            print("[RestTimer] Failed to start Live Activity: \(error)")
        }
    }

    static func stopTimer() {
        phaseUpdateTask?.cancel()
        phaseUpdateTask = nil

        guard let activity = currentActivity else { return }

        let finalState = RestTimerAttributes.ContentState(timerRunning: false, phase: .normal)

        Task {
            await activity.end(
                ActivityContent(state: finalState, staleDate: nil),
                dismissalPolicy: .immediate
            )
        }

        currentActivity = nil
    }

    private static func schedulePhaseUpdates(startTime: Date, staleDate: Date) {
        phaseUpdateTask?.cancel()

        phaseUpdateTask = Task {
            let warningDelay = startTime.addingTimeInterval(60).timeIntervalSinceNow
            if warningDelay > 0 {
                try? await Task.sleep(for: .seconds(warningDelay))
            }
            guard !Task.isCancelled, let activity = currentActivity else { return }

            let warningState = RestTimerAttributes.ContentState(timerRunning: true, phase: .warning)
            await activity.update(ActivityContent(state: warningState, staleDate: staleDate))

            let urgentDelay = startTime.addingTimeInterval(120).timeIntervalSinceNow
            if urgentDelay > 0 {
                try? await Task.sleep(for: .seconds(urgentDelay))
            }
            guard !Task.isCancelled, let activity = currentActivity else { return }

            let urgentState = RestTimerAttributes.ContentState(timerRunning: true, phase: .urgent)
            await activity.update(ActivityContent(state: urgentState, staleDate: staleDate))
        }
    }
}
