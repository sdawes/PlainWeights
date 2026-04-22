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
            HStack(spacing: 14) {
                Image("Timer_Icon")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                    .foregroundStyle(.green)
                VStack(alignment: .leading, spacing: 3) {
                    Text("RESTING")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.35))
                        .tracking(0.8)
                    Text(context.attributes.exerciseName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                Spacer()
                Text(timerInterval: context.attributes.startTime...context.attributes.startTime.addingTimeInterval(context.attributes.maxDuration),
                     countsDown: false)
                    .font(.system(size: 28, weight: .bold).monospacedDigit())
                    .foregroundStyle(context.isStale ? .gray : context.state.timerColor)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80, alignment: .trailing)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .activityBackgroundTint(.black)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("").opacity(0)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("").opacity(0)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 14) {
                        Image("Timer_Icon")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                            .foregroundStyle(.green)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("RESTING")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.white.opacity(0.35))
                                .tracking(0.8)
                            Text(context.attributes.exerciseName)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                        }
                        Spacer()
                        Text(timerInterval: context.attributes.startTime...context.attributes.startTime.addingTimeInterval(context.attributes.maxDuration),
                             countsDown: false)
                            .font(.system(size: 24, weight: .bold).monospacedDigit())
                            .foregroundStyle(context.state.timerColor)
                            .frame(width: 70, alignment: .trailing)
                            .clipped()
                    }
                }
            } compactLeading: {
                Image("Timer_Icon")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                    .foregroundStyle(.green)
            } compactTrailing: {
                Text(timerInterval: context.attributes.startTime...context.attributes.startTime.addingTimeInterval(context.attributes.maxDuration),
                     countsDown: false)
                    .font(.system(size: 14, weight: .bold).monospacedDigit())
                    .foregroundStyle(context.isStale ? .gray : context.state.timerColor)
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
