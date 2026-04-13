//
//  PlainWeightsTimerLiveActivity.swift
//  PlainWeightsTimer
//
//  Rest timer Live Activity for Dynamic Island and Lock Screen.
//  Shows elapsed rest time after adding a set.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Widget

struct PlainWeightsTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RestTimerAttributes.self) { context in
            // Lock Screen / Banner
            lockScreenView(context: context)
                .activityBackgroundTint(.black)
                .activitySystemActionForegroundColor(.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view (long press on Dynamic Island)
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 20))
                        .foregroundStyle(.white.opacity(0.8))
                }

                DynamicIslandExpandedRegion(.trailing) {
                    timerText(startTime: context.attributes.startTime)
                        .font(.system(size: 24, weight: .semibold).monospacedDigit())
                        .foregroundStyle(.white)
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.exerciseName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    timerProgressBar(startTime: context.attributes.startTime, maxDuration: context.attributes.maxDuration)
                        .padding(.top, 4)
                }
            } compactLeading: {
                // Compact: left side — timer icon
                Image(systemName: "timer")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.8))
            } compactTrailing: {
                // Compact: right side — elapsed time
                timerText(startTime: context.attributes.startTime)
                    .font(.system(size: 14, weight: .semibold).monospacedDigit())
                    .foregroundStyle(.white)
            } minimal: {
                // Minimal: just an icon
                Image(systemName: "timer")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }

    // MARK: - Lock Screen View

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<RestTimerAttributes>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 18))
                .foregroundStyle(.white.opacity(0.7))

            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.exerciseName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)

                Text("Rest Timer")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            timerText(startTime: context.attributes.startTime)
                .font(.system(size: 28, weight: .semibold).monospacedDigit())
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Timer Components

    /// System-managed timer text that counts up from startTime
    @ViewBuilder
    private func timerText(startTime: Date) -> some View {
        Text(timerInterval: startTime...startTime.addingTimeInterval(180), countsDown: false)
    }

    /// Progress bar showing elapsed time as fraction of max duration
    @ViewBuilder
    private func timerProgressBar(startTime: Date, maxDuration: TimeInterval) -> some View {
        ProgressView(timerInterval: startTime...startTime.addingTimeInterval(maxDuration), countsDown: false)
            .tint(.white.opacity(0.8))
    }
}

// MARK: - Preview

extension RestTimerAttributes {
    fileprivate static var preview: RestTimerAttributes {
        RestTimerAttributes(
            exerciseName: "Bench Press",
            startTime: Date(),
            maxDuration: 180
        )
    }
}

extension RestTimerAttributes.ContentState {
    fileprivate static var running: RestTimerAttributes.ContentState {
        RestTimerAttributes.ContentState(timerRunning: true)
    }
}

#Preview("Notification", as: .content, using: RestTimerAttributes.preview) {
    PlainWeightsTimerLiveActivity()
} contentStates: {
    RestTimerAttributes.ContentState.running
}
