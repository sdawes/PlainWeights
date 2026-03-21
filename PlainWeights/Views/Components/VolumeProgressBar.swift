//
//  VolumeProgressBar.swift
//  PlainWeights
//
//  Reusable component for displaying volume progress comparison
//  Shows a horizontal bar comparing current volume against a target (last session or best)
//

import SwiftUI

struct VolumeProgressBar: View {
    @Environment(ThemeManager.self) private var themeManager

    let currentVolume: Double
    let targetVolume: Double
    let targetLabel: String  // "Last" or "Best"
    let isRepsOnly: Bool  // True for bodyweight exercises (compare reps, not volume)
    var lastSetWeight: Double? = nil  // Weight of the most recent set (for reps remaining hint)
    var showCurrentValue: Bool = false  // Whether to show current value above the bar

    // Computed color based on comparison
    private var progressColor: Color {
        if currentVolume > targetVolume {
            return .green
        } else if currentVolume < targetVolume {
            return .red
        } else {
            return .blue
        }
    }

    // Progress ratio (clamped to 1.0 for bar width)
    private var progressRatio: CGFloat {
        guard targetVolume > 0 else { return 0 }
        return min(CGFloat(currentVolume / targetVolume), 1.0)
    }

    // Delta between current and target
    private var delta: Double {
        currentVolume - targetVolume
    }

    // Reps remaining to beat the target at the last set's weight
    private var repsRemaining: Int? {
        guard !isRepsOnly, delta < 0,
              let weight = lastSetWeight, weight > 0 else { return nil }
        return Int(abs(delta) / weight) + 1
    }

    var body: some View {
        VStack(spacing: 6) {
            // Current value label (right-aligned, above bar)
            if showCurrentValue {
                HStack {
                    Spacer()
                    if isRepsOnly {
                        HStack(spacing: 0) {
                            Text("\(Int(currentVolume))")
                                .font(themeManager.effectiveTheme.dataFont(size: 15, weight: .bold))
                            Text(" reps")
                                .font(themeManager.effectiveTheme.dataFont(size: 15, weight: .medium))
                        }
                        .foregroundStyle(themeManager.effectiveTheme.primaryText)
                    } else {
                        HStack(spacing: 0) {
                            Text(Formatters.formatVolume(themeManager.displayWeight(currentVolume)))
                                .font(themeManager.effectiveTheme.dataFont(size: 15, weight: .bold))
                            Text(" \(themeManager.weightUnit.displayName)")
                                .font(themeManager.effectiveTheme.dataFont(size: 15, weight: .medium))
                        }
                        .foregroundStyle(themeManager.effectiveTheme.primaryText)
                    }
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(themeManager.effectiveTheme.muted)
                        .frame(height: 8)

                    // Progress fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(
                            width: progressRatio * geometry.size.width,
                            height: 8
                        )
                        .animation(.easeInOut(duration: 0.3), value: currentVolume)
                }
            }
            .frame(height: 8)

            // Labels row
            HStack {
                Text("Total volume progress")
                    .font(themeManager.effectiveTheme.interFont(size: 12))
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)

                Spacer()

                // Delta display
                if delta > 0 {
                    if isRepsOnly {
                        Text("+\(Int(delta)) \(Int(delta) == 1 ? "rep" : "reps") over")
                            .font(themeManager.effectiveTheme.dataFont(size: 12, weight: .medium))
                            .foregroundStyle(progressColor)
                    } else if let weight = lastSetWeight, weight > 0 {
                        let repsOver = Int(delta / weight)
                        if repsOver > 0 {
                            Text("+\(repsOver) \(repsOver == 1 ? "rep" : "reps") over")
                                .font(themeManager.effectiveTheme.dataFont(size: 12, weight: .medium))
                                .foregroundStyle(progressColor)
                        }
                    }
                } else if delta < 0 {
                    if let reps = repsRemaining {
                        Text("\(reps) \(reps == 1 ? "rep" : "reps") to beat")
                            .font(themeManager.effectiveTheme.dataFont(size: 12, weight: .medium))
                            .foregroundStyle(progressColor)
                    } else if isRepsOnly {
                        Text("\(Int(abs(delta) + 1)) reps to beat")
                            .font(themeManager.effectiveTheme.dataFont(size: 12, weight: .medium))
                            .foregroundStyle(progressColor)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: targetVolume)
    }
}

#Preview {
    VStack(spacing: 20) {
        // Exceeding target (green)
        VolumeProgressBar(
            currentVolume: 2280,
            targetVolume: 1680,
            targetLabel: "Last",
            isRepsOnly: false
        )

        // Below target (red)
        VolumeProgressBar(
            currentVolume: 2280,
            targetVolume: 3220,
            targetLabel: "Best",
            isRepsOnly: false
        )

        // Reps-only: exceeding target (green)
        VolumeProgressBar(
            currentVolume: 45,
            targetVolume: 38,
            targetLabel: "Last",
            isRepsOnly: true
        )

        // Reps-only: below target (red)
        VolumeProgressBar(
            currentVolume: 30,
            targetVolume: 45,
            targetLabel: "Best",
            isRepsOnly: true
        )
    }
    .padding()
    .environment(ThemeManager())
}
