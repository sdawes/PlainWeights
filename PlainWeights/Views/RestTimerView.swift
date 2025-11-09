//
//  RestTimerView.swift
//  PlainWeights
//
//  Created by Claude on 09/11/2025.
//
//  Rest timer component that counts up from when a set was added.
//  Turns red after 3 minutes to indicate excessive rest time.

import SwiftUI

struct RestTimerView: View {
    let startTime: Date

    private let redThreshold: TimeInterval = 180 // 3 minutes in seconds

    var body: some View {
        TimelineView(.periodic(from: startTime, by: 1.0)) { context in
            let elapsed = context.date.timeIntervalSince(startTime)
            let isOverThreshold = elapsed >= redThreshold

            Text(Formatters.formatDuration(elapsed))
                .font(.caption)
                .foregroundStyle(isOverThreshold ? .red : .secondary)
        }
    }
}
