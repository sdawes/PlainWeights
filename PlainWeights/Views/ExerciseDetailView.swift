//
//  ExerciseDetailView.swift
//  PlainWeights
//
//  Exercise detail view with metrics and sets history
//

import SwiftUI
import SwiftData

// MARK: - ExerciseDetailView

struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    let exercise: Exercise
    @Query private var sets: [ExerciseSet]
    @State private var addSetConfig: AddSetConfig?

    // Form state
    @State private var noteText: String = ""
    @State private var showingDeleteAlert = false
    @State private var showingNotesSheet = false
    @State private var showingEditSheet = false


    // Cached data for performance
    @State private var todaySets: [ExerciseSet] = []
    @State private var historicDayGroups: [ExerciseDataGrouper.DayGroup] = []

    // Today's volume for running total
    private var todaysVolume: Double {
        TodaySessionCalculator.getTodaysVolume(from: Array(sets))
    }

    // Last session volume (baseline) - returns 0 if no data
    private var lastSessionVolume: Double {
        LastSessionCalculator.getLastSessionVolume(from: Array(sets))
    }

    // Best ever volume (upper target) - exclude today
    private var bestSessionVolume: Double {
        let setsExcludingToday = Array(sets).filter {
            Calendar.current.startOfDay(for: $0.timestamp) < Calendar.current.startOfDay(for: Date())
        }
        return BestSessionCalculator.calculateBestDayMetrics(from: setsExcludingToday)?.totalVolume ?? 0
    }

    // Percentage of baseline (treat 0 as 1 to always show percentage)
    private var percentOfBaseline: Int {
        let divisor = max(lastSessionVolume, 1)
        return Int(round((todaysVolume / divisor) * 100))
    }

    // Percentage of upper target (treat 0 as 1 to always show percentage)
    private var percentOfTarget: Int {
        let divisor = max(bestSessionVolume, 1)
        return Int(round((todaysVolume / divisor) * 100))
    }

    // Color for baseline comparison
    private var baselineColor: Color {
        if percentOfBaseline < 100 { return .red }
        if percentOfBaseline > 100 { return .green }
        return .blue
    }

    // Color for target comparison
    private var targetColor: Color {
        if percentOfTarget < 100 { return .red }
        if percentOfTarget > 100 { return .green }
        return .blue
    }

    init(exercise: Exercise) {
        self.exercise = exercise
        let id = exercise.persistentModelID
        _sets = Query(
            filter: #Predicate<ExerciseSet> { $0.exercise?.persistentModelID == id },
            sort: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        _noteText = State(initialValue: exercise.note ?? "")
    }

    // MARK: - Extracted Views

    private var titleSection: some View {
        Section {
            Text(exercise.name)
                .font(.jetBrainsMono(.title, weight: .semiBold))
                .foregroundStyle(Color.pw_cyan)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    var body: some View {
        List {
            titleSection

            // Target metrics cards (Previous session + Best Ever)
            Section {
                TargetMetricsCard(
                    exercise: exercise,
                    sets: sets
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(themeManager.currentTheme.cardBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(themeManager.currentTheme.borderColor, lineWidth: 1)
                )
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            // Today's sets section
            if !todaySets.isEmpty {
                Section {
                    ForEach(todaySets.indices, id: \.self) { index in
                        let set = todaySets[index]
                        SetRowView(
                            set: set,
                            setNumber: todaySets.count - index,
                            isFirst: index == 0,
                            isLast: index == todaySets.count - 1,
                            onTap: { addSetConfig = .edit(set: set, exercise: exercise) },
                            onDelete: { deleteSet(set) },
                            allSets: (set.isWarmUp || set.isBonus) ? nil : Array(sets),
                            showTimer: index == 0  // Only show timer on most recent set
                        )
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TODAY")
                            .font(.jetBrainsMono(.subheadline, weight: .semiBold))
                            .foregroundStyle(.white)
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundStyle(Color.pw_cyan)
                            Text("—")
                                .foregroundStyle(.secondary)
                            Text(Date().formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))
                                .font(.jetBrainsMono(.footnote))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }

            // Historic sets: one section per day group
            if !historicDayGroups.isEmpty {
                ForEach(historicDayGroups.indices, id: \.self) { groupIndex in
                    let dayGroup = historicDayGroups[groupIndex]
                    Section {
                        ForEach(dayGroup.sets.indices, id: \.self) { index in
                            let set = dayGroup.sets[index]
                            SetRowView(
                                set: set,
                                setNumber: dayGroup.sets.count - index,
                                isFirst: index == 0,
                                isLast: index == dayGroup.sets.count - 1,
                                onTap: { addSetConfig = .edit(set: set, exercise: exercise) },
                                onDelete: { deleteSet(set) }
                            )
                        }
                    } header: {
                        VStack(alignment: .leading, spacing: 4) {
                            if groupIndex == 0 {
                                Text("PREVIOUS")
                                    .font(.jetBrainsMono(.subheadline, weight: .semiBold))
                                    .foregroundStyle(.white)
                            }
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(Color.pw_cyan)
                                Text("—")
                                    .foregroundStyle(.secondary)
                                Text(Formatters.formatAbbreviatedDayHeader(dayGroup.date))
                                    .font(.jetBrainsMono(.footnote))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
            }

            // Empty state (only when no sets at all)
            if sets.isEmpty {
                Section {
                    Text("No sets yet")
                        .foregroundStyle(.secondary)
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .listSectionSpacing(0)
        .scrollContentBackground(.hidden)
        .background(AnimatedGradientBackground())
        .scrollDismissesKeyboard(.immediately)
        .contentMargins(.top, 0, for: .scrollContent)
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                let lastWorkingSet = sets.first(where: { !$0.isWarmUp && !$0.isBonus })
                addSetConfig = .previous(
                    exercise: exercise,
                    weight: lastWorkingSet?.weight,
                    reps: lastWorkingSet?.reps
                )
            }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            .frame(width: 48, height: 48)
            .background(.blue)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    ExerciseChartDetailView(exercise: exercise, sets: Array(sets))
                } label: {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.callout)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingNotesSheet = true }) {
                    Image(systemName: "note.text")
                        .font(.callout)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditSheet = true }) {
                    Image(systemName: "pencil")
                        .font(.callout)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                IconComponents.deleteIcon {
                    showingDeleteAlert = true
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Exercise", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteExercise()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete \"\(exercise.name)\" and all its sets. This action cannot be undone.")
        }
        .sheet(item: $addSetConfig) { config in
            AddSetView(
                exercise: config.exercise,
                initialWeight: config.initialWeight,
                initialReps: config.initialReps,
                setToEdit: config.setToEdit
            )
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        .sheet(isPresented: $showingNotesSheet) {
            ExerciseNotesSheet(
                exercise: exercise,
                noteText: $noteText,
                onSave: updateNote
            )
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        .sheet(isPresented: $showingEditSheet) {
            AddExerciseView(exerciseToEdit: exercise)
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        .onAppear {
            updateCachedData()
        }
        .onChange(of: sets) { _, _ in
            updateCachedData()
        }
    }

    // MARK: - Data Management

    /// Update cached expensive calculations when sets change
    private func updateCachedData() {
        let (todaysData, historicData) = ExerciseDataGrouper.separateTodayFromHistoric(sets: sets)
        todaySets = todaysData
        historicDayGroups = historicData
    }

    private func deleteSet(_ set: ExerciseSet) {
        do {
            try ExerciseSetService.deleteSet(set, context: context)
        } catch {
            print("Error deleting set: \(error)")
        }
    }

    private func updateNote() {
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        exercise.note = trimmed.isEmpty ? nil : trimmed
        exercise.bumpUpdated()

        do {
            try context.save()
        } catch {
            print("Error updating note: \(error)")
        }
    }

    /// Delete the exercise and all its associated sets (cascade delete)
    private func deleteExercise() {
        context.delete(exercise)
        do {
            try context.save()
            dismiss()
        } catch {
            print("Failed to delete exercise: \(error)")
        }
    }

}
