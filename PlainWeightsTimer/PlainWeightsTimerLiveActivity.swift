//
//  PlainWeightsTimerLiveActivity.swift
//  PlainWeightsTimer
//
//  Bare-minimum rest timer Live Activity.
//  Shows only the elapsed timer in the Dynamic Island trailing slot.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PlainWeightsTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RestTimerAttributes.self) { context in
            Color.clear
                .frame(height: 1)
                .activityBackgroundTint(.black)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text(timerInterval: context.attributes.startTime...context.attributes.startTime.addingTimeInterval(context.attributes.maxDuration),
                         countsDown: false)
                        .font(.system(size: 22, weight: .semibold).monospacedDigit())
                        .foregroundStyle(context.state.timerColor)
                        .fixedSize(horizontal: true, vertical: false)
                }
            } compactLeading: {
                Image("Timer_Icon")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.green)
            } compactTrailing: {
                Text(timerInterval: context.attributes.startTime...context.attributes.startTime.addingTimeInterval(context.attributes.maxDuration),
                     countsDown: false)
                    .font(.system(size: 14, weight: .bold).monospacedDigit())
                    .foregroundStyle(context.state.timerColor)
                    .frame(width: 50, alignment: .trailing)
                    .clipped()
            } minimal: {
                Text(timerInterval: context.attributes.startTime...context.attributes.startTime.addingTimeInterval(context.attributes.maxDuration),
                     countsDown: false)
                    .font(.system(size: 12, weight: .bold).monospacedDigit())
                    .foregroundStyle(context.state.timerColor)
                    .multilineTextAlignment(.center)
                    .frame(width: 36, alignment: .center)
                    .clipped()
            }
        }
    }
}

#Preview("Notification", as: .content, using: RestTimerAttributes(exerciseName: "Bench Press", startTime: Date(), maxDuration: 180)) {
    PlainWeightsTimerLiveActivity()
} contentStates: {
    RestTimerAttributes.ContentState(timerRunning: true, phase: .normal)
}
