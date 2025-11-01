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

            // Metrics container section
            Section {
                ExerciseMetricsView(
                    exercise: exercise,
                    sets: sets,
                    selectedMode: $selectedMode,
                    addSetConfig: $addSetConfig
                )
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))

            // Today's sets section
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
                                    .foregroundStyle(Color(red: 0.7, green: 0.1, blue: 0.1).opacity(0.7))
                                    .textCase(.uppercase)
                            }

                            if set.isDropSet {
                                Image(systemName: "chevron.down.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.teal)
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

            // Historic sets: one section per day group
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
                                        .foregroundStyle(Color(red: 0.7, green: 0.1, blue: 0.1).opacity(0.7))
                                        .textCase(.uppercase)
                                }

                                if set.isDropSet {
                                    Image(systemName: "chevron.down.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(.teal)
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
        .listStyle(.insetGrouped)
        .listSectionSpacing(6)
        .scrollContentBackground(.hidden)
        .background(Color(red: 0.91, green: 0.93, blue: 0.99))
        .scrollDismissesKeyboard(.immediately)
        .contentMargins(.top, 0, for: .scrollContent)
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
                initialReps: config.initialReps
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
}
