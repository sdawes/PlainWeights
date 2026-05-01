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

        // Most recent workout across all exercises in the group.
        let mostRecentDate = exercises.compactMap { $0.lastWorkoutDate }.max()

        VStack(alignment: .leading, spacing: 0) {
            // Header — split into expand tap target (name/count) and
            // ellipsis Menu (always visible, left of chevron).
            HStack(alignment: .center, spacing: 0) {
                // Name + count + staleness: tapping anywhere here toggles expansion.
                Button(action: onToggle) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(group.name)
                            .font(themeManager.effectiveTheme.interFont(size: 18, weight: .semibold))
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)
                        subtitleRow(exercises: exercises, mostRecentDate: mostRecentDate)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)

                // Ellipsis menu — always visible, independent tap target.
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

                // Chevron — part of the expand button visually but
                // rendered outside it to keep the Menu tap target clean.
                Button(action: onToggle) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .padding(.leading, 12)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 14)

            // Body — exercise rows only when expanded.
            if isExpanded {
                VStack(spacing: 0) {
                    if exercises.isEmpty {
                        Text("No exercises yet. Tap ··· to edit.")
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

    // MARK: - Subtitle row

    /// Exercise count + optional staleness dot and relative date.
    @ViewBuilder
    private func subtitleRow(exercises: [Exercise], mostRecentDate: Date?) -> some View {
        HStack(spacing: 6) {
            Text("\(exercises.count) \(exercises.count == 1 ? "exercise" : "exercises")")
                .font(themeManager.effectiveTheme.captionFont)
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)

            if let date = mostRecentDate {
                Text("·")
                    .font(themeManager.effectiveTheme.captionFont)
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)

                Circle()
                    .fill(stalenessColor(for: date))
                    .frame(width: 6, height: 6)

                Text(relativeDateString(for: date))
                    .font(themeManager.effectiveTheme.captionFont)
                    .foregroundStyle(stalenessColor(for: date))
            }
        }
    }

    // MARK: - Staleness helpers

    /// Green = today, orange = 14+ days, red = 30+ days, muted otherwise.
    private func stalenessColor(for date: Date) -> Color {
        let days = Calendar.current.dateComponents([.day], from: date, to: .now).day ?? 0
        if days == 0 { return .green }
        if days >= 30 { return .red }
        if days >= 14 { return .orange }
        return themeManager.effectiveTheme.mutedForeground
    }

    private func relativeDateString(for date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: .now).day ?? 0
        switch days {
        case 0: return "Today"
        case 1: return "Yesterday"
        default: return "\(days) days ago"
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
