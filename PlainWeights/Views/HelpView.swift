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
                .accessibilityLabel("Close")
            }
            .padding(.bottom, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    helpSection(
                        title: "Exercises",
                        body: "Create an exercise for each movement you do in the gym. Add primary and secondary muscle tags to track your training split."
                    )

                    helpSection(
                        title: "Sets",
                        body: "Tap an exercise and log each set as you go. Add the weight and reps. Mark sets as warm-up, drop set, assisted, pause, timed or superset if needed — these don't change the totals, they're just for your own reference."
                    )

                    helpSection(
                        title: "Sessions",
                        body: "A session is all the sets you log on a given day. There's no start or stop button — just log sets and the app groups them automatically."
                    )

                    helpSection(
                        title: "Groups",
                        body: "Tap the stack icon to organise exercises into named bundles like Push Day or Pull Day. The same exercise can live in more than one group. Tapping an exercise from inside a group tags the sets you log with that group, so each group card can show you which exercises you've done today as part of that session."
                    )

                    helpSection(
                        title: "Progress",
                        body: "The app tracks your total volume (weight × reps) each session. After your second session you'll see a comparison card showing today's max weight, reps and volume against your last session or all-time best."
                    )

                    helpSection(
                        title: "Personal Bests",
                        body: "When you lift a heavier weight than ever before on an exercise, the set is marked with a gold star and the today's-sets card briefly flashes gold. Every set counts — including warm-ups."
                    )

                    helpSection(
                        title: "Charts",
                        body: "Each exercise has a progress chart showing max weight and reps over time. Use the time range picker to zoom in or out. Tap the Trend toggle to overlay linear trend lines for weight and reps so you can see direction at a glance."
                    )

                    helpSection(
                        title: "History",
                        body: "Tap the clock icon to open History. Pick a time period — Last, Week, Month or Year — and switch between Summary, Progress and Muscle to see your totals, every exercise day by day with up/down indicators, and your training split by muscle group."
                    )

                    helpSection(
                        title: "Compared to last session",
                        body: "On the Progress tab in History, each row shows three small arrows for max weight (W), max reps (R) and total volume (V). Green up means you improved, red down means it dropped, amber means no change, a dash means no comparison was possible. Tap Legend at the top for the full key."
                    )

                    helpSection(
                        title: "Rest Timer",
                        body: "When you log a set, a rest timer appears in the Dynamic Island and on the Lock Screen. It counts up to three minutes — long-press the floating pill or tap a different exercise to stop it early. The actual rest time you took is saved against the set."
                    )

                    helpSection(
                        title: "iCloud Sync",
                        body: "Your exercises, sets and groups all sync automatically via iCloud. If you delete and reinstall the app, or switch to a new device, everything will restore on its own. Initial sync after a fresh install can take a couple of minutes."
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
