//
//  RestTimerAttributes.swift
//  PlainWeights
//
//  ActivityAttributes for the rest timer Live Activity.
//  Shared between the main app and the widget extension.
//

import ActivityKit
import Foundation

struct RestTimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var timerRunning: Bool
    }

    // Static data — set when activity starts, never changes
    var exerciseName: String
    var startTime: Date
    var maxDuration: TimeInterval  // 180 seconds
}
