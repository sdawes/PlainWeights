//
//  ExerciseDetailView.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 16/08/2025.
//

import SwiftUI
import SwiftData

/// Configuration for AddSetView presentation with reliable parameter delivery
struct AddSetConfig: Identifiable {
    let id = UUID()
    let exercise: Exercise
    let initialWeight: Double?
    let initialReps: Int?

    /// Create config for empty "Add Set" presentation
    static func empty(exercise: Exercise) -> AddSetConfig {
        AddSetConfig(exercise: exercise, initialWeight: nil, initialReps: nil)
    }

    /// Create config for "Add Previous Set" with pre-populated values
    static func previous(exercise: Exercise, weight: Double?, reps: Int?) -> AddSetConfig {
        AddSetConfig(exercise: exercise, initialWeight: weight, initialReps: reps)
    }
}

struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let exercise: Exercise
    @Query private var sets: [ExerciseSet]
    
    // Local form state
    @State private var weightText = ""
    @State private var repsText = ""
    @State private var exerciseName: String = ""
    @State private var noteText: String = ""
    @State private var showingDeleteAlert = false
    @State private var addSetConfig: AddSetConfig?

    @FocusState private var nameFocused: Bool
    @FocusState private var notesFocused: Bool
    @FocusState private var focusedField: Field?
    @State private var keyboardHeight: CGFloat = 0

    // Memoized expensive calculations - updated only when sets change
    @State private var progressState: ProgressTracker.ProgressState?
    @State private var todaySets: [ExerciseSet] = []
    @State private var historicDayGroups: [ExerciseDataGrouper.DayGroup] = []
    
    enum Field {
        case weight, reps
    }

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
            // Title and notes row (no card background)
            Section {
                VStack(alignment: .leading, spacing: 2) {
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

                    // Notes as subtitle
                    TextField("Add notes about form, target muscles, etc...", text: $noteText)
                        .font(.caption.italic())
                        .foregroundStyle(.tertiary)
                        .textFieldStyle(.plain)
                        .lineLimit(1)
                        .focused($notesFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            notesFocused = false
                            updateNote()
                        }
                        .onChange(of: noteText) { _, newValue in
                            if newValue.count > 40 {
                                noteText = String(newValue.prefix(40))
                            }
                        }
                }
                .padding(.horizontal, 8)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .padding(.bottom, 20)

            // Exercise summary metrics "card"
            if let progressState = progressState {
                Section {
                    ExerciseSummaryView(
                        progressState: progressState,
                        sets: sets,
                        exercise: exercise,
                        addSetConfig: $addSetConfig,
                        lastWorkingSetValues: lastWorkingSetValues
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear) // keep the card's own background
                    .listRowInsets(EdgeInsets())
                }
            }

            // Today's sets "card"
            if !todaySets.isEmpty {
                Section {
                    ForEach(todaySets, id: \.persistentModelID) { set in
                        HStack(alignment: .bottom) {
                            Text(ExerciseSetFormatters.formatSet(set))
                                .monospacedDigit()
                                .foregroundStyle(set.isWarmUp ? .secondary : .primary)

                            Spacer()

                            if set.isWarmUp {
                                Text("WARM UP")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.red.opacity(0.7))
                                    .textCase(.uppercase)
                            }

                            Text(Formatters.formatTimeHM(set.timestamp))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteSet(set)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    Text("TODAY'S SETS")
                        .font(.footnote)
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                }
            }

            // Historic sets: one "card" per day group
            if !historicDayGroups.isEmpty {
                ForEach(historicDayGroups, id: \.date) { dayGroup in
                    Section {
                        ForEach(dayGroup.sets, id: \.persistentModelID) { set in
                            HStack(alignment: .bottom) {
                                Text(ExerciseSetFormatters.formatSet(set))
                                    .monospacedDigit()
                                    .foregroundStyle(set.isWarmUp ? .secondary : .primary)

                                Spacer()

                                if set.isWarmUp {
                                    Text("WARM UP")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.red.opacity(0.7))
                                        .textCase(.uppercase)
                                }

                                Text(Formatters.formatTimeHM(set.timestamp))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteSet(set)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Text(Formatters.formatAbbreviatedDayHeader(dayGroup.date))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Spacer()

                            Text("\(Formatters.formatVolume(dayGroup.volume)) kg")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
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
        .listStyle(.insetGrouped) // card-like grouped sections with system styling
        .listSectionSpacing(6)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .scrollDismissesKeyboard(.immediately)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if nameFocused {
                    Button("Done") {
                        nameFocused = false
                        updateExerciseName()
                    }
                } else if notesFocused {
                    Button("Done") {
                        notesFocused = false
                        updateNote()
                    }
                } else {
                    IconComponents.deleteIcon {
                        showingDeleteAlert = true
                    }
                }
            }

        }
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
                initialReps: config.initialReps
            )
        }
        .onAppear {
            updateCachedData()
        }
        .onChange(of: sets) { _, _ in
            updateCachedData()
        }
    }

    // MARK: - Business Logic Methods

    /// Update cached expensive calculations when sets change
    private func updateCachedData() {
        progressState = ProgressTracker.createProgressState(from: sets)
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

    /// Get the weight and reps values from the last working (non-warm-up) set
    private var lastWorkingSetValues: (weight: Double?, reps: Int?) {
        guard let lastWorkingSet = sets.first(where: { !$0.isWarmUp }) else {
            return (nil, nil)
        }

        // Return actual values including zeros for pre-population
        return (lastWorkingSet.weight, lastWorkingSet.reps)
    }

    private func isMostRecentSet(_ set: ExerciseSet, in sets: [ExerciseSet]) -> Bool {
        set.persistentModelID == sets.first?.persistentModelID
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
}
