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
    let exercise: Exercise
    @Query private var sets: [ExerciseSet]
    @State private var addSetConfig: AddSetConfig?

    // Form state
    @State private var exerciseName: String = ""
    @State private var noteText: String = ""
    @FocusState private var nameFocused: Bool
    @State private var showingDeleteAlert = false
    @State private var showingNotesSheet = false

    // Metric mode selection
    @State private var selectedMode: MetricMode = .last

    // Cached data for performance
    @State private var todaySets: [ExerciseSet] = []
    @State private var historicDayGroups: [ExerciseDataGrouper.DayGroup] = []

    init(exercise: Exercise) {
        self.exercise = exercise
        let id = exercise.persistentModelID
        _sets = Query(
            filter: #Predicate<ExerciseSet> { $0.exercise?.persistentModelID == id },
            sort: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        _exerciseName = State(initialValue: exercise.name)
        _noteText = State(initialValue: exercise.note ?? "")
    }

    var body: some View {
        List {
            // Title and notes section (no card background)
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    TextField("Title", text: $exerciseName)
                        .font(.largeTitle.bold())
                        .textFieldStyle(.plain)
                        .focused($nameFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            nameFocused = false
                            updateExerciseName()
                        }
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                .padding(.horizontal, 8)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .padding(.bottom, 0)

            // Target metrics card (Last Max Weight / Best Ever)
            Section {
                TargetMetricsCard(
                    exercise: exercise,
                    sets: sets,
                    selectedMode: $selectedMode
                )
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(16)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 4, trailing: 0))

            // This Set metrics card (only when sets added today - moved here for logical grouping)
            // COMMENTED OUT - Testing new inline progress design
//            if TodaySessionCalculator.getTodaysSets(from: sets).first(where: { !$0.isWarmUp }) != nil {
//                Section {
//                    ThisSetCard(
//                        exercise: exercise,
//                        sets: sets,
//                        selectedMode: selectedMode
//                    )
//                    .padding(16)
//                    .background(Color(.systemBackground))
//                    .clipShape(RoundedRectangle(cornerRadius: 16))
//                }
//                .listRowSeparator(.hidden)
//                .listRowBackground(Color.clear)
//                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
//            }

            // Chart card
            Section {
                ChartCard(
                    exercise: exercise,
                    sets: sets
                )
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 8, trailing: 0))

            // Today's sets section
            if !todaySets.isEmpty {
                Section {
                    ForEach(todaySets.indices, id: \.self) { index in
                        let set = todaySets[index]
                        // Calculate cumulative volume up to and including this set
                        let cumulativeVolume = todaySets.prefix(index + 1).reduce(0.0) { total, s in
                            total + (s.weight * Double(s.reps))
                        }
                        SetRowView(
                            set: set,
                            onTap: { addSetConfig = .edit(set: set, exercise: exercise) },
                            onDelete: { deleteSet(set) },
                            progressComparison: calculateProgressComparison(for: set),
                            cumulativeVolume: cumulativeVolume
                        )
                    }
                } header: {
                    Text("TODAY'S SETS")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .foregroundStyle(.black)
                }
            }

            // Historic sets: one section per day group
            if !historicDayGroups.isEmpty {
                ForEach(historicDayGroups, id: \.date) { dayGroup in
                    Section {
                        ForEach(Array(dayGroup.sets.enumerated()), id: \.element.persistentModelID) { index, set in
                            // Calculate cumulative volume up to and including this set within the day
                            let cumulativeVolume = dayGroup.sets.prefix(index + 1).reduce(0.0) { total, s in
                                total + (s.weight * Double(s.reps))
                            }
                            SetRowView(
                                set: set,
                                onTap: { addSetConfig = .edit(set: set, exercise: exercise) },
                                onDelete: { deleteSet(set) },
                                cumulativeVolume: cumulativeVolume
                            )
                        }
                    } header: {
                        HStack {
                            Text(Formatters.formatAbbreviatedDayHeader(dayGroup.date))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.black)

                            Spacer()

                            Text("\(Formatters.formatVolume(dayGroup.volume)) kg")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.black)
                        }
                        .padding(.bottom, 4)
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
        .listStyle(.insetGrouped)
        .listSectionSpacing(10)
        .scrollContentBackground(.hidden)
        .background(AnimatedGradientBackground())
        .scrollDismissesKeyboard(.immediately)
        .contentMargins(.top, 0, for: .scrollContent)
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                let lastWorkingSet = sets.first(where: { !$0.isWarmUp })
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
                Button(action: { showingNotesSheet = true }) {
                    Image(systemName: "note.text")
                        .font(.callout)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if nameFocused {
                    Button("Done") {
                        nameFocused = false
                        updateExerciseName()
                    }
                } else {
                    IconComponents.deleteIcon {
                        showingDeleteAlert = true
                    }
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
        }
        .sheet(isPresented: $showingNotesSheet) {
            ExerciseNotesSheet(
                exercise: exercise,
                noteText: $noteText,
                onSave: updateNote
            )
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

    private func updateExerciseName() {
        let trimmed = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != exercise.name else { return }

        exercise.name = trimmed
        exercise.bumpUpdated()

        do {
            try context.save()
        } catch {
            print("Error updating exercise name: \(error)")
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

    /// Calculate progress comparison data for the first set of today
    private func calculateProgressComparison(for currentSet: ExerciseSet) -> ProgressComparison? {
        // Get comparison data based on selected mode
        if selectedMode == .last {
            // Compare against last session's max weight
            let progressState = ProgressTracker.createProgressState(from: sets)
            guard let lastInfo = progressState.lastCompletedDayInfo else {
                return nil
            }

            let weightDelta = currentSet.weight - lastInfo.maxWeight
            let repsDelta = currentSet.reps - lastInfo.maxWeightReps

            // Calculate volume progress
            let todayVolume = TodaySessionCalculator.getTodaysVolume(from: sets)
            let volumeDelta = todayVolume - lastInfo.volume
            let volumeProgress = lastInfo.volume > 0 ? volumeDelta / lastInfo.volume : 0

            return ProgressComparison(
                weightDelta: weightDelta,
                repsDelta: repsDelta,
                comparisonMode: "(vs Last)",
                volumeProgress: volumeProgress,
                lastSessionVolume: lastInfo.volume
            )
        } else {
            // Compare against best ever
            let setsExcludingToday = sets.filter {
                Calendar.current.startOfDay(for: $0.timestamp) < Calendar.current.startOfDay(for: Date())
            }
            guard let bestMetrics = BestSessionCalculator.calculateBestDayMetrics(from: setsExcludingToday) else {
                return nil
            }

            let weightDelta = currentSet.weight - bestMetrics.maxWeight
            let repsDelta = currentSet.reps - bestMetrics.repsAtMaxWeight

            // Calculate volume progress
            let todayVolume = TodaySessionCalculator.getTodaysVolume(from: sets)
            let volumeDelta = todayVolume - bestMetrics.totalVolume
            let volumeProgress = bestMetrics.totalVolume > 0 ? volumeDelta / bestMetrics.totalVolume : 0

            return ProgressComparison(
                weightDelta: weightDelta,
                repsDelta: repsDelta,
                comparisonMode: "(vs Best)",
                volumeProgress: volumeProgress,
                lastSessionVolume: bestMetrics.totalVolume
            )
        }
    }
}
