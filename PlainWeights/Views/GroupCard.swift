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
    /// Drives the "Add new exercise" sheet — creates a brand-new
    /// exercise and adds it to this group in one flow.
    @State private var showingAddNewExercise = false

    /// Cached sort + status derived from `group`. Computing these inline in
    /// `body` is expensive (lastWorkoutDate scans an exercise's sets for
    /// each comparison) and body fires on every theme/app-storage tick.
    /// Rebuilt on appear, when membership changes, and when set data
    /// changes via the `.setDataChanged` notification.
    @State private var sortedExercises: [Exercise] = []
    @State private var doneExerciseIDsToday: Set<PersistentIdentifier> = []
    /// Summary of the most recent historical day with activity — drives the
    /// idle pill's colour and label. Nil when the group has never been
    /// touched. Only consulted in the `.idle` path; today's pill states use
    /// the live status enum.
    @State private var cachedIdleSummary: IdleSummary? = nil

    /// One historical day's outcome — was that session a full completion or
    /// a partial? Kept in the cache and consumed by `idleSubtitle`.
    private struct IdleSummary: Equatable {
        enum Kind { case completed, partial }
        let kind: Kind
        let date: Date
        let doneCount: Int
        let totalCount: Int
    }

    var body: some View {
        let status = groupSessionStatus(exercises: sortedExercises, doneIDsToday: doneExerciseIDsToday)

        VStack(alignment: .leading, spacing: 0) {
            // Header — split into expand tap target (name/count) and
            // ellipsis Menu (always visible, left of chevron).
            HStack(alignment: .center, spacing: 14) {
                // Name + count + staleness: tapping anywhere here toggles expansion.
                Button(action: onToggle) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(group.name)
                            .font(themeManager.effectiveTheme.interFont(size: 18, weight: .semibold))
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)

                        subtitleRow(status: status, total: sortedExercises.count)
                            .padding(.top, 6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)

                // Ellipsis menu — always visible, independent tap target.
                Menu {
                    Button("Add or remove exercises", systemImage: "checklist") {
                        onEditExercises()
                    }
                    Button("Create new exercise", systemImage: "plus") {
                        showingAddNewExercise = true
                    }
                    Button("Duplicate group", systemImage: "plus.square.on.square") {
                        duplicateGroup()
                    }
                    Button("Rename", systemImage: "pencil") {
                        showingRenameSheet = true
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
            .padding(.vertical, 14)
            .padding(.horizontal, 14)

            // Body — exercise rows only when expanded.
            if isExpanded {
                VStack(spacing: 0) {
                    if sortedExercises.isEmpty {
                        Text("No exercises yet. Tap ··· to edit.")
                            .font(themeManager.effectiveTheme.subheadlineFont)
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.bottom, 14)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(sortedExercises) { exercise in
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
        .onAppear { rebuildCaches() }
        .onChange(of: group.exercises?.count) { _, _ in rebuildCaches() }
        .onReceive(NotificationCenter.default.publisher(for: .setDataChanged)) { _ in
            rebuildCaches()
        }
        .sheet(isPresented: $showingRenameSheet) {
            GroupNameSheet(mode: .rename(currentName: group.name)) { newName in
                commitRename(newName)
            }
        }
        .sheet(isPresented: $showingAddNewExercise) {
            AddExerciseView { newExercise in
                addNewExerciseToGroup(newExercise)
            }
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
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

    // MARK: - Cache rebuild

    /// Recompute the sorted exercises, today's done-IDs, and last-logged date
    /// from the current group state. Cheap to run on demand; expensive when
    /// run on every body invocation, which is what this avoids.
    private func rebuildCaches() {
        sortedExercises = (group.exercises ?? []).sorted { a, b in
            let aDate = a.lastWorkoutDate ?? a.lastUpdated
            let bDate = b.lastWorkoutDate ?? b.lastUpdated
            return aDate > bDate
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let groupSets = group.groupSets ?? []
        doneExerciseIDsToday = Set(
            groupSets
                .filter { calendar.startOfDay(for: $0.timestamp) == today }
                .compactMap { $0.exercise?.id }
        )
        cachedIdleSummary = computeIdleSummary(
            groupSets: groupSets,
            members: sortedExercises,
            calendar: calendar
        )
    }

    /// Find the most recent historical day with any group-tagged set and
    /// classify it as either a full completion (every member exercise logged)
    /// or a partial session. Returns nil when there are no members or no
    /// sets to summarise.
    private func computeIdleSummary(groupSets: [ExerciseSet], members: [Exercise], calendar: Calendar) -> IdleSummary? {
        let memberIDs = Set(members.map { $0.id })
        guard !memberIDs.isEmpty, !groupSets.isEmpty else { return nil }

        // Bucket every set's exercise into its calendar-day-start.
        var doneByDay: [Date: Set<PersistentIdentifier>] = [:]
        for set in groupSets {
            guard let exerciseID = set.exercise?.id else { continue }
            let day = calendar.startOfDay(for: set.timestamp)
            doneByDay[day, default: []].insert(exerciseID)
        }

        guard let mostRecentDay = doneByDay.keys.max(),
              let doneIDs = doneByDay[mostRecentDay] else {
            return nil
        }

        let doneCount = memberIDs.intersection(doneIDs).count
        let totalCount = memberIDs.count
        let kind: IdleSummary.Kind = doneCount >= totalCount ? .completed : .partial
        return IdleSummary(kind: kind, date: mostRecentDay, doneCount: doneCount, totalCount: totalCount)
    }

    // MARK: - Subtitle row

    @ViewBuilder
    private func subtitleRow(status: GroupSessionStatus, total: Int) -> some View {
        if total == 0 {
            // Empty group — italic muted text, no pill (a "0 / 0" pill would be confusing).
            Text("No exercises yet")
                .font(themeManager.effectiveTheme.interFont(size: 11, weight: .medium))
                .italic()
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
        } else {
            switch status {
            case .idle:
                idlePill(total: total)
            case .inProgress(let done, let totalCount):
                statusPill(accent: .orange, label: "\(done) / \(totalCount) TODAY")
            case .completedToday:
                statusPill(accent: .green, label: "\(total) / \(total) TODAY")
            }
        }
    }

    /// Idle pill — derived from `cachedIdleSummary`. Grey "0 / N" when the
    /// group has never been touched, amber when the last activity day was
    /// partial, green when it was a full completion. Date suffix shows when
    /// the most recent activity day was.
    @ViewBuilder
    private func idlePill(total: Int) -> some View {
        if let summary = cachedIdleSummary {
            let accent: Color = summary.kind == .completed ? .green : .orange
            statusPill(
                accent: accent,
                label: "\(summary.doneCount) / \(summary.totalCount) \(dateLabel(for: summary.date))"
            )
        } else {
            statusPill(
                accent: themeManager.effectiveTheme.mutedForeground,
                label: "0 / \(total)"
            )
        }
    }

    /// Single source of pill styling — accent-coloured dot + tracked label
    /// inside a capsule background tinted with the accent at 18% opacity.
    @ViewBuilder
    private func statusPill(accent: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(accent)
                .frame(width: 6, height: 6)
            Text(label)
                .font(themeManager.effectiveTheme.interFont(size: 11, weight: .semibold))
                .tracking(0.4)
        }
        .foregroundStyle(accent)
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
        .background(accent.opacity(0.18))
        .clipShape(.capsule)
    }

    /// Format a historical date as a pill suffix: "YESTERDAY" or "· ND AGO".
    /// "TODAY" is included defensively but the idle path only runs when
    /// there's no activity today, so it won't normally surface.
    private func dateLabel(for date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: .now).day ?? 0
        switch days {
        case 0: return "TODAY"
        case 1: return "YESTERDAY"
        default: return "· \(days)D AGO"
        }
    }

    // MARK: - Group session status

    private enum GroupSessionStatus: Equatable {
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

    // MARK: - Actions

    /// Add a freshly-created exercise to this group, save, and navigate
    /// into it with group context so any sets logged immediately get
    /// stamped with this group's `sourceGroup`. The Exercise itself was
    /// already inserted by AddExerciseView before this callback ran.
    private func addNewExerciseToGroup(_ exercise: Exercise) {
        var members = group.exercises ?? []
        members.append(exercise)
        group.exercises = members
        try? modelContext.save()
        navigationPath.append(GroupExerciseDestination(exercise: exercise, group: group))
    }

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
