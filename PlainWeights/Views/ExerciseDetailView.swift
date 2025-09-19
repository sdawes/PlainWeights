//
//  ExerciseDetailView.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 16/08/2025.
//

import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let exercise: Exercise
    @Query private var sets: [ExerciseSet]
    
    // Local form state
    @State private var weightText = ""
    @State private var repsText = ""
    @State private var exerciseName: String = ""
    @State private var showingDeleteAlert = false

    @FocusState private var nameFocused: Bool
    @FocusState private var focusedField: Field?
    
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
    }

    var body: some View {
        List {
            // Title row
            TextField("Title", text: $exerciseName)
                .font(.largeTitle.bold())
                .textFieldStyle(.plain)
                .focused($nameFocused)
                .submitLabel(.done)
                .onSubmit { 
                    nameFocused = false
                    updateExerciseName()
                }
                .listRowSeparator(.hidden)
                .padding(.vertical, 8)
            
            // Volume tracking metrics row
            if let progressState = createProgressState() {
                VolumeMetricsView(progressState: progressState, sets: sets)
            }
            
            // Quick-add row
            QuickAddView(
                weightText: $weightText,
                repsText: $repsText,
                focusedField: $focusedField,
                canAddSet: canAddSet,
                addSet: addSet
            )
            
            // History label row
            Text("HISTORIC SETS")
                .font(.footnote)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
                .listRowSeparator(.hidden)
                .padding(.vertical, 4)
            
            // Grouped history rows
            if sets.isEmpty {
                Text("No sets yet")
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
            } else {
                HistorySectionView(
                    sets: sets,
                    dayGroups: createDayGroups(),
                    isMostRecentSet: isMostRecentSet,
                    repeatSet: repeatSet,
                    deleteSet: deleteSet,
                    toggleWarmUpStatus: toggleWarmUpStatus
                )
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if nameFocused {
                    Button("Done") {
                        nameFocused = false
                        updateExerciseName()
                    }
                } else {
                    Button {
                        showingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }

            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
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
    }

    // MARK: - Business Logic Methods
    
    private func createProgressState() -> ProgressTracker.ProgressState? {
        ProgressTracker.createProgressState(from: sets)
    }
    
    private func createDayGroups() -> [ExerciseDataGrouper.DayGroup] {
        ExerciseDataGrouper.createDayGroups(from: sets)
    }
    
    private func addSet() {
        guard let weight = Double(weightText),
              let reps = Int(repsText),
              weight > 0,
              reps > 0 else { 
            print("AddSet failed: Invalid input - weight: \(weightText), reps: \(repsText)")
            return 
        }
        
        print("Adding set: \(weight)kg x \(reps) reps")
        let set = ExerciseSet(weight: weight, reps: reps, isWarmUp: false, exercise: exercise)
        context.insert(set)
        
        do {
            try context.save()
            print("Set saved successfully")
            clearForm()
        } catch {
            print("Error saving set: \(error)")
        }
    }
    
    private func repeatSet(_ set: ExerciseSet) {
        print("Repeating set: \(set.weight)kg x \(set.reps) reps")
        let newSet = ExerciseSet(
            weight: set.weight,
            reps: set.reps,
            exercise: exercise
        )
        context.insert(newSet)
        
        do {
            try context.save()
            print("Repeated set saved successfully")
        } catch {
            print("Error repeating set: \(error)")
        }
    }
    
    private func deleteSet(_ set: ExerciseSet) {
        context.delete(set)
        
        do {
            try context.save()
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
    
    private func clearForm() {
        weightText = ""
        repsText = ""
        focusedField = nil
    }

    private func toggleWarmUpStatus(_ set: ExerciseSet) {
        set.isWarmUp.toggle()

        do {
            try context.save()
            let status = set.isWarmUp ? "warm-up" : "working set"
            print("Toggled warm-up status for set: \(set.weight)kg x \(set.reps) - now \(status)")
        } catch {
            print("Error toggling warm-up status: \(error)")
        }
    }

    private var canAddSet: Bool {
        !weightText.isEmpty && !repsText.isEmpty
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
}

// MARK: - Volume Metrics View

private struct VolumeMetricsView: View {
    let progressState: ProgressTracker.ProgressState
    let sets: [ExerciseSet]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Max weight from last session
            if let maxWeightInfo = VolumeAnalytics.getMaxWeightFromLastDay(from: sets) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Last max weight")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    HStack {
                        Text("\(Formatters.formatWeight(maxWeightInfo.weight)) kg")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.primary)

                        Spacer()

                        if !maxWeightInfo.allReps.isEmpty {
                            let repsText = maxWeightInfo.allReps.map(String.init).joined(separator: ", ")
                            Text("\(repsText) reps")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // Total volume from last session
            if let totalVolume = progressState.lastCompletedDayInfo?.volume {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Last session total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    Text("\(Formatters.formatVolume(totalVolume)) kg")
                        .font(.headline.bold())
                        .foregroundStyle(.primary)
                }
            }

            // Today's progress section
            TodayProgressDisplay(progressState: progressState)
        }
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
        .listRowSeparator(.hidden)
        .padding(.vertical, 8)
    }
}

// MARK: - Quick Add View

private struct QuickAddView: View {
    @Binding var weightText: String
    @Binding var repsText: String
    @FocusState.Binding var focusedField: ExerciseDetailView.Field?
    let canAddSet: Bool
    let addSet: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                TextField("Weight", text: $weightText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .weight)
                    .frame(maxWidth: .infinity)

                TextField("Reps", text: $repsText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .reps)
                    .frame(maxWidth: .infinity)

                Button(action: addSet) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.tint)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .disabled(!canAddSet)
            }
        }
        .listRowSeparator(.hidden)
        .padding(.vertical, 8)
    }
}

// MARK: - History Section View

private struct HistorySectionView: View {
    let sets: [ExerciseSet]
    let dayGroups: [ExerciseDataGrouper.DayGroup]
    let isMostRecentSet: (ExerciseSet, [ExerciseSet]) -> Bool
    let repeatSet: (ExerciseSet) -> Void
    let deleteSet: (ExerciseSet) -> Void
    let toggleWarmUpStatus: (ExerciseSet) -> Void
    
    var body: some View {
        ForEach(dayGroups, id: \.date) { dayGroup in
            Section {
                ForEach(dayGroup.sets, id: \.persistentModelID) { set in
                    HStack {
                        HStack(spacing: 6) {
                            Text("\(Formatters.formatWeight(set.weight)) kg × \(set.reps)")
                                .monospacedDigit()
                                .foregroundStyle(set.isWarmUp ? .secondary : .primary)

                        }

                        Spacer()

                        HStack(spacing: 8) {
                            Text(set.timestamp.formatted(
                                Date.FormatStyle()
                                    .hour().minute()
                                    .locale(Locale(identifier: "en_GB_POSIX"))
                            ))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                            // Warm-up toggle button
                            Button {
                                toggleWarmUpStatus(set)
                            } label: {
                                Image(systemName: set.isWarmUp ? "flame.circle.fill" : "flame.circle")
                                    .font(.callout)
                                    .foregroundStyle(set.isWarmUp ? .orange : .secondary)
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())

                            // Repeat button for any set
                            Button {
                                repeatSet(set)
                            } label: {
                                Image(systemName: "arrow.clockwise.circle")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                        }
                    }
                    .listRowSeparator(dayGroup.isFirst(set) ? .hidden : .visible, edges: .top)
                    .listRowSeparator(dayGroup.isLast(set) ? .hidden : .visible, edges: .bottom)
                    .swipeActions {
                        Button("Delete", role: .destructive) {
                            deleteSet(set)
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
}

// MARK: - Last Session View

private struct LastSessionView: View {
    let weightGroups: [WeightGroup]
    let totalVolume: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Last session header
            Text("Last session")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            // Weight group breakdown (one line per weight)
            ForEach(weightGroups.indices, id: \.self) { index in
                Text(weightGroups[index].description)
                    .font(.headline)
                    .monospacedDigit()
            }

            // Total volume for last session
            if let totalVolume = totalVolume {
                Text("Total: \(Formatters.formatVolume(totalVolume)) kg")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
    }
}



// MARK: - Today Progress Display

private struct TodayProgressDisplay: View {
    let progressState: ProgressTracker.ProgressState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Text("Lifted today")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            // Volume and percentage row
            HStack {
                Text("\(Formatters.formatVolume(progressState.todayVolume)) kg")
                    .font(.headline.bold())
                    .foregroundStyle(.primary)

                Spacer()

                if progressState.lastCompletedDayInfo != nil {
                    Text("\(progressState.percentOfLast)% of last")
                        .font(.headline)
                        .foregroundStyle(progressState.barFillColor)
                }
            }

            // Modern progress bar
            if progressState.lastCompletedDayInfo != nil {
                ProgressView(value: Double(progressState.progressBarRatio))
                    .progressViewStyle(LinearProgressViewStyle(tint: progressState.barFillColor))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    .animation(.easeInOut(duration: 0.3), value: progressState.progressBarRatio)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}