//
//  RestTimerAttributes.swift
//  PlainWeights
//
//  ActivityAttributes for the rest timer Live Activity.
//  Shared between the main app and the widget extension.
//

import ActivityKit
import SwiftUI

struct RestTimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var timerRunning: Bool
    }

    var exerciseName: String
    var startTime: Date
    var maxDuration: TimeInterval
}
