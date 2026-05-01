//
//  GroupCard.swift
//  PlainWeights
//
//  Single-group accordion card rendered on the Groups screen. Tapping
//  the header invokes the supplied toggle closure; while expanded, the
//  member exercises are listed beneath. Tapping any exercise pushes the
//  shared ExerciseDetailView via the bound navigation path.
//
//  A thin divider with a trailing ellipsis-circle Menu gives access to
//  Rename, Edit exercises, and Delete without cluttering the card body.
//

import SwiftUI
import SwiftData

struct GroupCard: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext

    let group: ExerciseGroup
    let isExpanded: Bool
    let onToggle: () -> Void
    /// Called when the user taps the "Edit exercises" action. The parent
    /// (ExerciseGroupsView) sets its draft context to present the
    /// selection cover.
    let onEditExercises: () -> Void
    @Binding var navigationPath: NavigationPath

    /// Drives the rename sheet.
    @State private var showingRenameSheet = false
    /// Drives the delete-group confirmation dialog.
    @State private var showingDeleteConfirmation = false

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

            // Body — divider + ellipsis menu + exercise rows when expanded.
            // Opacity transition; height changes are animated by the
            // .animation(_:value:) below, which scopes the timing.
            if isExpanded {
                VStack(spacing: 0) {
                    // Thin divider with trailing ellipsis menu.
                    HStack(spacing: 10) {
                        Rectangle()
                            .fill(themeManager.effectiveTheme.borderColor)
                            .frame(height: 1)

                        Menu {
                            Button("Rename", systemImage: "pencil") {
                                showingRenameSheet = true
                            }
                            Button("Edit exercises", systemImage: "list.bullet") {
                                onEditExercises()
                            }
                            Divider()
                            Button("Delete group", systemImage: "trash", role: .destructive) {
                                showingDeleteConfirmation = true
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                                .frame(width: 28, height: 28)
                                .background(themeManager.effectiveTheme.muted)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 10)
                    .padding(.bottom, 10)

                    if exercises.isEmpty {
                        Text("No exercises yet. Tap ••• above to edit.")
                            .font(themeManager.effectiveTheme.subheadlineFont)
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.bottom, 14)
                    } else {
                        VStack(spacing: 8) {
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
                        .padding(.bottom, 12)
                    }
                }
                .transition(.opacity)
            }
        }
        .background(themeManager.effectiveTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.easeInOut(duration: 0.22), value: isExpanded)
        .sheet(isPresented: $showingRenameSheet) {
            GroupNameSheet(mode: .rename(currentName: group.name)) { newName in
                commitRename(newName)
            }
        }
        .alert(
            "Delete \(group.name)?",
            isPresented: $showingDeleteConfirmation
        ) {
            Button("Delete", role: .destructive) {
                deleteGroup()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The exercises themselves are kept — they just leave this group.")
        }
    }

    // MARK: - Actions

    /// Persist the new name. The sheet has already trimmed and validated.
    private func commitRename(_ newName: String) {
        group.name = newName
        try? modelContext.save()
    }

    /// Delete the entire group. The Exercise → ExerciseGroup
    /// relationship's default delete rule is .nullify, so deleting a
    /// group simply removes it from each member exercise's `groups`
    /// array — no exercises are deleted.
    private func deleteGroup() {
        modelContext.delete(group)
        try? modelContext.save()
    }
}
