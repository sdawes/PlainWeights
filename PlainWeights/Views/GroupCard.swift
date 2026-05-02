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

        // Set of exercise IDs that have at least one set logged today
        // with `sourceGroup` equal to this group. Used to render the
        // per-row "Done" indicator and to drive the group session
        // status — computed once per render, not per row.
        let today = Calendar.current.startOfDay(for: .now)
        let doneExerciseIDsToday: Set<PersistentIdentifier> = Set(
            (group.groupSets ?? [])
                .filter { Calendar.current.startOfDay(for: $0.timestamp) == today }
                .compactMap { $0.exercise?.id }
        )

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
                        subtitleRow(exercises: exercises, doneIDsToday: doneExerciseIDsToday)
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
                    Button("Duplicate group", systemImage: "plus.square.on.square") {
                        duplicateGroup()
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
                                    navigationPath.append(GroupExerciseDestination(exercise: exercise, group: group))
                                } label: {
                                    GroupExerciseRow(
                                        exercise: exercise,
                                        isDoneFromGroupToday: doneExerciseIDsToday.contains(exercise.id)
                                    )
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

    @ViewBuilder
    private func subtitleRow(exercises: [Exercise], doneIDsToday: Set<PersistentIdentifier>) -> some View {
        let status = groupSessionStatus(exercises: exercises, doneIDsToday: doneIDsToday)
        HStack(spacing: 6) {
            switch status {
            case .completedToday:
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.green)
                Text("Logged today")
                    .font(themeManager.effectiveTheme.captionFont)
                    .foregroundStyle(.green)

            case .inProgress(let done, let total):
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.orange)
                Text("\(done)/\(total) logged today")
                    .font(themeManager.effectiveTheme.captionFont)
                    .foregroundStyle(.orange)

            case .idle:
                Text("\(exercises.count) \(exercises.count == 1 ? "exercise" : "exercises")")
                    .font(themeManager.effectiveTheme.captionFont)
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)

                if let date = lastCompletedDate() {
                    Text("·")
                        .font(themeManager.effectiveTheme.captionFont)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    Text("Logged \(relativeDateString(for: date))")
                        .font(themeManager.effectiveTheme.captionFont)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                } else if !exercises.isEmpty {
                    Text("·")
                        .font(themeManager.effectiveTheme.captionFont)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    Image(systemName: "circle.dashed")
                        .font(.system(size: 12))
                        .foregroundStyle(.red)
                    Text("Nothing logged yet")
                        .font(themeManager.effectiveTheme.captionFont)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    // MARK: - Group session status

    private enum GroupSessionStatus {
        case idle
        case inProgress(done: Int, total: Int)
        case completedToday
    }

    private func groupSessionStatus(exercises: [Exercise], doneIDsToday: Set<PersistentIdentifier>) -> GroupSessionStatus {
        guard !exercises.isEmpty else { return .idle }
        guard !doneIDsToday.isEmpty else { return .idle }

        let allIDs = Set(exercises.map { $0.id })
        let doneCount = allIDs.intersection(doneIDsToday).count
        if doneCount == 0 { return .idle }
        if doneCount >= allIDs.count { return .completedToday }
        return .inProgress(done: doneCount, total: allIDs.count)
    }

    /// Most recent day on which every exercise in the group had at least
    /// one set logged within this group's context.
    private func lastCompletedDate() -> Date? {
        guard let exercises = group.exercises, !exercises.isEmpty,
              let groupSets = group.groupSets, !groupSets.isEmpty else { return nil }

        let allIDs = Set(exercises.map { $0.id })
        let calendar = Calendar.current
        let byDay = Dictionary(grouping: groupSets) {
            calendar.startOfDay(for: $0.timestamp)
        }
        return byDay
            .filter { (_, sets) in
                let covered = Set(sets.compactMap { $0.exercise?.id })
                return allIDs.isSubset(of: covered)
            }
            .keys
            .max()
    }

    // MARK: - Date helpers

    private func relativeDateString(for date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: .now).day ?? 0
        switch days {
        case 0: return "today"
        case 1: return "yesterday"
        default: return "\(days) days ago"
        }
    }

    // MARK: - Actions

    /// Create a copy of the group with the same exercises. The duplicate
    /// is inserted immediately so it appears in the list; the user can
    /// rename and edit it from there.
    private func duplicateGroup() {
        let copy = ExerciseGroup(
            name: "\(group.name) (copy)",
            exercises: group.exercises ?? []
        )
        modelContext.insert(copy)
        try? modelContext.save()
    }

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
