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

    var body: some View {
        VStack(spacing: 6) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(themeManager.currentTheme.muted)
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
                // Target label
                Text("\(targetLabel): \(Formatters.formatVolume(targetVolume)) kg")
                    .font(.caption)
                    .foregroundStyle(themeManager.currentTheme.mutedForeground)

                Spacer()

                // Delta display
                if delta != 0 {
                    Text(delta > 0 ? "+\(Formatters.formatVolume(delta))" : "\(Formatters.formatVolume(delta))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(progressColor)
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
            targetLabel: "Last"
        )

        // Below target (red)
        VolumeProgressBar(
            currentVolume: 2280,
            targetVolume: 3220,
            targetLabel: "Best"
        )

        // Equal (blue)
        VolumeProgressBar(
            currentVolume: 1500,
            targetVolume: 1500,
            targetLabel: "Last"
        )
    }
    .padding()
    .environment(ThemeManager())
}
