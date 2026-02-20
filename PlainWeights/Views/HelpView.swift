//
//  HelpView.swift
//  PlainWeights
//
//  How the app works — plain text guide for new users.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("How It Works")
                    .font(themeManager.effectiveTheme.title3Font)
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    helpSection(
                        title: "Exercises",
                        body: "Create an exercise for each movement you do in the gym. Tag them by muscle group to keep things organised."
                    )

                    helpSection(
                        title: "Sets",
                        body: "Tap an exercise and log each set as you go. Add the weight, reps, and a note if you like. Mark sets as warm-up, drop set, assisted, or other types if needed."
                    )

                    helpSection(
                        title: "Sessions",
                        body: "A session is all the sets you log on a given day. There's no start or stop button, just log sets and the app groups them automatically."
                    )

                    helpSection(
                        title: "Progress",
                        body: "The app tracks your total volume (weight x reps) each session. After your second session you'll see a progress bar comparing today against your last session or all time best."
                    )

                    helpSection(
                        title: "Personal Bests",
                        body: "When you lift a heavier weight than ever before on an exercise, the set is marked with a star. Personal bests are based on working sets only. Warm-ups don't count."
                    )

                    helpSection(
                        title: "Charts",
                        body: "Each exercise has a progress chart showing max weight and reps over time. Use the time range picker to zoom in or out. Activate the trend bar if needed."
                    )

                    helpSection(
                        title: "iCloud Sync",
                        body: "Your data syncs automatically via iCloud. If you delete and reinstall the app, or switch to a new device, your workout history will restore on its own."
                    )

                    Spacer(minLength: 40)
                }
                .padding(.top, 24)
            }
            .scrollIndicators(.hidden)
        }
        .padding(24)
        .background(themeManager.effectiveTheme.background)
    }

    @ViewBuilder
    private func helpSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(themeManager.effectiveTheme.interFont(size: 16, weight: .medium))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)
            Text(body)
                .font(themeManager.effectiveTheme.interFont(size: 15))
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
