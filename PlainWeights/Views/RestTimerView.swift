//
//  RestTimerView.swift
//  PlainWeights
//
//  Created by Claude on 09/11/2025.
//
//  Retro Casio-style rest timer that counts up from when a set was added.
//  Color-coded: black (0-1min), orange (1-3min), red (3min+), stops at 3:00.

import SwiftUI

struct RestTimerView: View {
    let startTime: Date

    var body: some View {
        TimelineView(.periodic(from: startTime, by: 1.0)) { context in
            // Cap elapsed time at 180 seconds (3 minutes)
            let rawElapsed = context.date.timeIntervalSince(startTime)
            let elapsed = min(rawElapsed, 180)

            // Color logic: black < 1min, orange 1-3min, red at 3min
            let color: Color = {
                if elapsed < 60 {
                    return .black
                } else if elapsed < 180 {
                    return Color.orange.opacity(0.8)
                } else {
                    return .red
                }
            }()

            Text(Formatters.formatDuration(elapsed))
                .font(.system(.title3, design: .monospaced, weight: .bold))
                .italic()
                .foregroundStyle(color)
        }
    }
}
