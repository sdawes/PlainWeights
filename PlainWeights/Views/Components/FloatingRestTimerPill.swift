//
//  FloatingRestTimerPill.swift
//  PlainWeights
//
//  Floating rest timer pill that appears at the bottom of ExerciseDetailView
//  after adding a set. Shows elapsed time counting up, auto-expires at 3:00.
//

import SwiftUI
import SwiftData

struct FloatingRestTimerPill: View {
    let set: ExerciseSet
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
    @State private var hasExpired = false

    private var isDark: Bool {
        themeManager.effectiveTheme == .dark
    }

    var body: some View {
        TimelineView(.periodic(from: set.timestamp, by: 1.0)) { context in
            let elapsed = context.date.timeIntervalSince(set.timestamp)

            if elapsed >= 180 || hasExpired {
                Color.clear
                    .frame(width: 0, height: 0)
                    .onAppear {
                        guard !hasExpired else { return }
                        hasExpired = true
                        try? ExerciseSetService.captureRestTimeExpiry(for: set, context: modelContext)
                    }
            } else {
                Button {
                    try? ExerciseSetService.captureRestTime(for: set, seconds: Int(elapsed), context: modelContext)
                } label: {
                    VStack(spacing: 4) {
                        Text(Formatters.formatDuration(elapsed))
                            .font(themeManager.effectiveTheme.dataFont(size: 28, weight: .bold))
                            .foregroundStyle(timerColor(for: elapsed))
                        Text("tap to stop")
                            .font(themeManager.effectiveTheme.captionFont)
                            .foregroundStyle(isDark ? .black.opacity(0.35) : .white.opacity(0.35))
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(isDark ? Color(white: 0.93) : Color.black)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func timerColor(for elapsed: TimeInterval) -> Color {
        if elapsed < 60 {
            return isDark ? .black : .white
        } else if elapsed < 120 {
            return isDark ? Color(red: 0.92, green: 0.45, blue: 0.18) : .orange
        } else {
            return isDark ? Color(red: 0.85, green: 0.20, blue: 0.20) : .red
        }
    }
}
