//
//  GroupCard.swift
//  PlainWeights
//
//  Single-group accordion card rendered on the Groups screen. Tapping
//  the header invokes the supplied toggle closure; while expanded, the
//  member exercises are listed beneath. Tapping any exercise pushes the
//  shared ExerciseDetailView via the bound navigation path.
//

import SwiftUI

struct GroupCard: View {
    @Environment(ThemeManager.self) private var themeManager

    let group: ExerciseGroup
    let isExpanded: Bool
    let onToggle: () -> Void
    @Binding var navigationPath: NavigationPath

    var body: some View {
        // Sort by most recent activity first — same rule as the main
        // exercise list. Falls back to lastUpdated when an exercise has
        // no sets yet.
        let exercises = (group.exercises ?? []).sorted { a, b in
            let aDate = a.lastWorkoutDate ?? a.lastUpdated
            let bDate = b.lastWorkoutDate ?? b.lastUpdated
            return aDate > bDate
        }

        VStack(alignment: .leading, spacing: 0) {
            // Header — tappable, drives expansion via the parent's closure.
            Button(action: onToggle) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(group.name)
                            .font(themeManager.effectiveTheme.interFont(size: 18, weight: .semibold))
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)
                        Text("\(exercises.count) \(exercises.count == 1 ? "exercise" : "exercises")")
                            .font(themeManager.effectiveTheme.captionFont)
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

            // Body — exercise rows when expanded.
            // Opacity transition; height changes are animated by the
            // .animation(_:value:) below, which scopes the timing.
            if isExpanded {
                Group {
                    if exercises.isEmpty {
                        Text("No exercises in this group.")
                            .font(themeManager.effectiveTheme.subheadlineFont)
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.bottom, 14)
                    } else {
                        VStack(spacing: 8) {
                            Rectangle()
                                .fill(themeManager.effectiveTheme.borderColor)
                                .frame(height: 1)
                                .padding(.horizontal, 5)

                            ForEach(exercises) { exercise in
                                Button {
                                    navigationPath.append(exercise)
                                } label: {
                                    ExerciseCard(exercise: exercise, compact: true)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(themeManager.effectiveTheme.muted.opacity(0.35))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 6)
                        .padding(.bottom, 12)
                    }
                }
                .transition(.opacity)
            }
        }
        .background(themeManager.effectiveTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.easeInOut(duration: 0.22), value: isExpanded)
    }
}
