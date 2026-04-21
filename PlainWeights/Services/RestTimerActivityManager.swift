//
//  RestTimerActivityManager.swift
//  PlainWeights
//
//  Manages the Live Activity for rest timer display in Dynamic Island
//  and Lock Screen. Starts when a set is added, stops when rest is captured.
//

import ActivityKit
import Foundation
import UIKit

@MainActor
enum RestTimerActivityManager {

    private(set) static var currentActivity: Activity<RestTimerAttributes>?

    private static var foregroundObserver: NSObjectProtocol?

    static func reconnectIfNeeded() {
        guard currentActivity == nil else { return }
        guard let activity = Activity<RestTimerAttributes>.activities.first else { return }

        let startTime = activity.attributes.startTime
        let elapsed = Date().timeIntervalSince(startTime)

        if elapsed >= 180 {
            Task { await activity.end(nil, dismissalPolicy: .immediate) }
            return
        }

        currentActivity = activity
        let staleDate = startTime.addingTimeInterval(180)

        let phase: RestTimerPhase
        if elapsed >= 120 { phase = .urgent }
        else if elapsed >= 60 { phase = .warning }
        else { phase = .normal }

        let state = RestTimerAttributes.ContentState(timerRunning: true, phase: phase)
        Task { await activity.update(ActivityContent(state: state, staleDate: staleDate)) }

        observeForeground(startTime: startTime, staleDate: staleDate)
    }

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
            observeForeground(startTime: startTime, staleDate: staleDate)
        } catch { }
    }

    static func stopTimer() {
        if let observer = foregroundObserver {
            NotificationCenter.default.removeObserver(observer)
            foregroundObserver = nil
        }

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

    private static func observeForeground(startTime: Date, staleDate: Date) {
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                updatePhaseForElapsedTime(startTime: startTime, staleDate: staleDate)
            }
        }
    }

    static func updatePhaseForElapsedTime(startTime: Date, staleDate: Date) {
        guard currentActivity != nil else { return }

        let elapsed = Date().timeIntervalSince(startTime)

        if elapsed >= 180 {
            stopTimer()
            return
        }

        let phase: RestTimerPhase
        if elapsed >= 120 { phase = .urgent }
        else if elapsed >= 60 { phase = .warning }
        else { phase = .normal }

        let state = RestTimerAttributes.ContentState(timerRunning: true, phase: phase)
        Task {
            await currentActivity?.update(ActivityContent(state: state, staleDate: staleDate))
        }
    }
}
