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

    // Today's cumulative reps (sum of all sets today)
    private var todaysTotalReps: Int {
        TodaySessionCalculator.getTodaysTotalReps(from: Array(sets))
    }

    // Session duration in minutes
    private var sessionDurationMinutes: Int? {
        TodaySessionCalculator.getSessionDurationMinutes(from: Array(sets))
    }

    // Check if this is a weighted exercise (any working set has weight > 0)
    private var isWeightedExercise: Bool {
        let workingSets = todaySets.filter { !$0.isWarmUp && !$0.isBonus }
        return workingSets.contains { $0.weight > 0 }
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
        .primary
    }

    // Color for target comparison
    private var targetColor: Color {
        .primary
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
            VStack(alignment: .leading, spacing: 0) {
                Text(exercise.name)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(themeManager.currentTheme.accent)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                if !exercise.tags.isEmpty {
                    TagPillsRow(tags: exercise.tags)
                        .padding(.top, 6)
                }
            }
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
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        .foregroundStyle(themeManager.currentTheme.borderColor)
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
                    VStack(alignment: .leading, spacing: 10) {
                        Text("TODAY")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(themeManager.currentTheme.primaryText)
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundStyle(themeManager.currentTheme.accent)
                            Text("—")
                                .foregroundStyle(.secondary)
                            Text(Date().formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))
                                .font(.footnote)
                                .foregroundStyle(themeManager.currentTheme.primaryText)
                            Spacer()
                            HStack(spacing: 8) {
                                // Show volume for weighted exercises, reps for bodyweight
                                if isWeightedExercise {
                                    Text("\(Formatters.formatVolume(todaysVolume)) kg")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("\(todaysTotalReps) reps")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                if let mins = sessionDurationMinutes {
                                    Text("|")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                    Text("\(mins) min")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
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
                        VStack(alignment: .leading, spacing: 10) {
                            if groupIndex == 0 {
                                Text("PREVIOUS")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(themeManager.currentTheme.primaryText)
                            }
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(themeManager.currentTheme.accent)
                                Text("—")
                                    .foregroundStyle(.secondary)
                                Text(Formatters.formatAbbreviatedDayHeader(dayGroup.date))
                                    .font(.footnote)
                                    .foregroundStyle(themeManager.currentTheme.primaryText)
                            }
                        }
                    }
                }
            }

            // Empty state (only when no sets at all)
            if sets.isEmpty {
                Section {
                    Text("No sets yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                                .foregroundStyle(themeManager.currentTheme.borderColor)
                        )
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
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
                    .foregroundStyle(themeManager.currentTheme.background)
            }
            .frame(width: 48, height: 48)
            .background(themeManager.currentTheme.primary)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
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
