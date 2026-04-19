//
//  RestTimerAttributes.swift
//  PlainWeights
//
//  ActivityAttributes for the rest timer Live Activity.
//  Shared between the main app and the widget extension.
//

import ActivityKit
import SwiftUI

enum RestTimerPhase: String, Codable, Hashable {
    case normal   // 0–59s
    case warning  // 60–119s
    case urgent   // 120–180s
}

struct RestTimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var timerRunning: Bool
        var phase: RestTimerPhase

        var timerColor: Color {
            switch phase {
            case .normal: return .white
            case .warning: return .orange
            case .urgent: return .red
            }
        }
    }

    var exerciseName: String
    var startTime: Date
    var maxDuration: TimeInterval
}
