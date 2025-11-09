//
//  RestTimerView.swift
//  PlainWeights
//
//  Created by Claude on 09/11/2025.
//
//  Retro Casio-style rest timer that counts up from when a set was added.
//  Color-coded: black (0-1min), orange (1-2min), red (2min+), stops at 2:00.

import SwiftUI

struct RestTimerView: View {
    let startTime: Date

    var body: some View {
        TimelineView(.periodic(from: startTime, by: 1.0)) { context in
            // Cap elapsed time at 120 seconds (2 minutes)
            let rawElapsed = context.date.timeIntervalSince(startTime)
            let elapsed = min(rawElapsed, 120)

            // Color logic: black < 1min, orange 1-2min, red at 2min
            let color: Color = {
                if elapsed < 60 {
                    return .black
                } else if elapsed < 120 {
                    return Color.orange.opacity(0.8)
                } else {
                    return .red
                }
            }()

            Text(Formatters.formatDuration(elapsed))
                .font(.caption)
                .italic()
                .foregroundStyle(color)
                .monospacedDigit()
                .frame(width: 48)
                .padding(.vertical, 6)
                .overlay(
                    Capsule()
                        .stroke(.black, lineWidth: 1)
                )
                .clipShape(Capsule())
        }
    }
}
