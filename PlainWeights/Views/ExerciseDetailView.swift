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
    @State private var noteText: String = ""
    @State private var showingDeleteAlert = false
    @State private var showingAddSet = false

    @FocusState private var nameFocused: Bool
    @FocusState private var focusedField: Field?
    @State private var keyboardHeight: CGFloat = 0
    
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
        ScrollViewReader { scrollProxy in
            List {
            // Title and notes row
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
                    .onSubmit {
                        updateNote()
                    }
                    .onChange(of: noteText) { _, newValue in
                        if newValue.count > 40 {
                            noteText = String(newValue.prefix(40))
                        }
                        updateNote()
                    }
            }
            .listRowSeparator(.hidden)
            .padding(.vertical, 8)

            // Exercise summary metrics row - always shown
            ExerciseSummaryView(progressState: createProgressState(), sets: sets)

            // Add Set button - positioned below summary, above historic sets
            HStack {
                Spacer()
                Button(action: { showingAddSet = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.caption)
                        Text("Add Set")
                            .font(.caption.bold())
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            .listRowSeparator(.hidden)
            .padding(.vertical, 4)

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
                    deleteSet: deleteSet
                )
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.immediately)
        }
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

        }
        .alert("Delete Exercise", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteExercise()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete \"\(exercise.name)\" and all its sets. This action cannot be undone.")
        }
        .sheet(isPresented: $showingAddSet) {
            AddSetView(exercise: exercise)
        }
    }

    // MARK: - Business Logic Methods
    
    private func createProgressState() -> ProgressTracker.ProgressState {
        ProgressTracker.createProgressState(from: sets)
    }
    
    private func createDayGroups() -> [ExerciseDataGrouper.DayGroup] {
        ExerciseDataGrouper.createDayGroups(from: sets)
    }
    
    private func addSet() {
        guard let (weight, reps) = ExerciseSetService.validateInput(
            weightText: weightText,
            repsText: repsText
        ) else {
            print("AddSet failed: Invalid input - weight: \(weightText), reps: \(repsText)")
            return
        }

        print("Adding set: \(weight)kg x \(reps) reps")
        do {
            try ExerciseSetService.addSet(
                weight: weight,
                reps: reps,
                to: exercise,
                context: context
            )
            print("Set saved successfully")
            clearForm()
        } catch {
            print("Error saving set: \(error)")
        }
    }
    
    private func repeatSet(_ set: ExerciseSet) {
        print("Repeating set: \(set.weight)kg x \(set.reps) reps")
        do {
            try ExerciseSetService.repeatSet(set, for: exercise, context: context)
            print("Repeated set saved successfully")
        } catch {
            print("Error repeating set: \(error)")
        }
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
    
    private func clearForm() {
        weightText = ""
        repsText = ""
        focusedField = nil
    }

    private func toggleWarmUpStatus(_ set: ExerciseSet) {
        do {
            try ExerciseSetService.toggleWarmUpStatus(set, context: context)
            let status = set.isWarmUp ? "warm-up" : "working set"
            print("Toggled warm-up status for set: \(set.weight)kg x \(set.reps) - now \(status)")
        } catch {
            print("Error toggling warm-up status: \(error)")
        }
    }

    private var canAddSet: Bool {
        ExerciseSetService.validateInput(weightText: weightText, repsText: repsText) != nil
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

// MARK: - Quick Add View

private struct QuickAddView: View {
    @Binding var weightText: String
    @Binding var repsText: String
    @FocusState.Binding var focusedField: ExerciseDetailView.Field?
    let canAddSet: Bool
    let addSet: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            // Weight input - compact
            VStack(alignment: .leading, spacing: 2) {
                Text("Weight (kg)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                TextField("0", text: $weightText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .weight)
            }
            .frame(maxWidth: .infinity)

            // Reps input - compact
            VStack(alignment: .leading, spacing: 2) {
                Text("Reps")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                TextField("0", text: $repsText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .reps)
            }
            .frame(maxWidth: .infinity)

            // Compact plus button
            Button(action: addSet) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(canAddSet ? Color.accentColor : Color.gray.opacity(0.4))
            }
            .buttonStyle(.plain)
            .disabled(!canAddSet)
            .contentShape(Circle())
            .padding(.top, 12) // Align with text fields
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .padding(.vertical, 2)
    }
}

// MARK: - History Section View

private struct HistorySectionView: View {
    let sets: [ExerciseSet]
    let dayGroups: [ExerciseDataGrouper.DayGroup]
    let isMostRecentSet: (ExerciseSet, [ExerciseSet]) -> Bool
    let deleteSet: (ExerciseSet) -> Void
    
    var body: some View {
        ForEach(dayGroups, id: \.date) { dayGroup in
            Section {
                ForEach(dayGroup.sets, id: \.persistentModelID) { set in
                    HStack(alignment: .bottom) {
                        Text("\(Formatters.formatWeight(set.weight)) kg × \(set.reps)")
                            .monospacedDigit()
                            .foregroundStyle(set.isWarmUp ? .secondary : .primary)

                        Spacer()

                        if set.isWarmUp {
                            Text("WARM UP")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.red.opacity(0.7))
                                .textCase(.uppercase)
                        }

                        Text(set.timestamp.formatted(
                            Date.FormatStyle()
                                .hour().minute()
                                .locale(Locale(identifier: "en_GB_POSIX"))
                        ))
                        .font(.caption)
                        .foregroundStyle(.secondary)
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

