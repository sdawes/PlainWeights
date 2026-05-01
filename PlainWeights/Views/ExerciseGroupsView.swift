//
//  ExerciseGroupsView.swift
//  PlainWeights
//
//  Lists all saved ExerciseGroups. Each group is rendered as a GroupCard —
//  tap a card's header to expand it accordion-style and reveal its
//  exercises. Tapping an exercise pushes the existing ExerciseDetailView,
//  so all set logging / PB tracking continues to flow against the one
//  underlying Exercise regardless of which group the user came from.
//

import SwiftUI
import SwiftData

struct ExerciseGroupsView: View {
    @Environment(ThemeManager.self) private var themeManager

    /// Most recently created groups first.
    @Query(sort: \ExerciseGroup.createdDate, order: .reverse)
    private var groups: [ExerciseGroup]

    @Binding var navigationPath: NavigationPath

    /// Which group cards are currently expanded. UUID-keyed so the state
    /// survives reorderings of `groups`.
    @State private var expandedGroupIDs: Set<UUID> = []

    var body: some View {
        Group {
            if groups.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(groups) { group in
                            GroupCard(
                                group: group,
                                isExpanded: expandedGroupIDs.contains(group.id),
                                onToggle: { toggleExpansion(for: group) },
                                navigationPath: $navigationPath
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(AnimatedGradientBackground())
        .navigationTitle("Groups")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
    }

    private func toggleExpansion(for group: ExerciseGroup) {
        withAnimation(.easeInOut(duration: 0.22)) {
            if expandedGroupIDs.contains(group.id) {
                expandedGroupIDs.remove(group.id)
            } else {
                expandedGroupIDs.insert(group.id)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("No groups yet")
                .font(themeManager.effectiveTheme.title2Font)
                .foregroundStyle(themeManager.effectiveTheme.primaryText)
            Text("On the exercise list, tap the checklist button to enter selection mode, tick the exercises you want, then tap the Save group button.")
                .font(themeManager.effectiveTheme.subheadlineFont)
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }
}
