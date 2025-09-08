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
    let exercise: Exercise
    @Query private var sets: [ExerciseSet]
    
    // Local form state
    @State private var weightText = ""
    @State private var repsText = ""
    @State private var exerciseName: String = ""
    
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
                VolumeMetricsView(progressState: progressState)
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
                    deleteSet: deleteSet
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
        let set = ExerciseSet(weight: weight, reps: reps, exercise: exercise)
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
    }
    
    private var canAddSet: Bool {
        !weightText.isEmpty && !repsText.isEmpty
    }
    
    private func isMostRecentSet(_ set: ExerciseSet, in sets: [ExerciseSet]) -> Bool {
        set.persistentModelID == sets.first?.persistentModelID
    }
}

// MARK: - Volume Metrics View

private struct VolumeMetricsView: View {
    let progressState: ProgressTracker.ProgressState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Last lifted (heaviest weight + reps from last completed day)
            if let lastInfo = progressState.lastCompletedDayInfo {
                Text("Last lifted: \(Formatters.formatWeight(lastInfo.maxWeight)) kg × \(lastInfo.maxWeightReps) reps")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            // Last total volume
            if let lastInfo = progressState.lastCompletedDayInfo {
                Text("Last total: \(Formatters.formatVolume(lastInfo.volume)) kg")
                    .font(.title2)
                    .bold()
                    .monospacedDigit()
            }
            
            // Today's volume with progress percentage
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Today: \(Formatters.formatVolume(progressState.todayVolume)) kg")
                    .font(.title2)
                    .bold()
                    .monospacedDigit()

                if progressState.showProgressBar {
                    Text("· \(progressState.percentOfLast)% of last")
                        .font(.headline)
                        .monospacedDigit()
                        .foregroundStyle(progressState.barFillColor)
                        .accessibilityLabel("You have reached \(progressState.percentOfLast) percent of your last daily total")
                }
            }
            
            // Progress bar (if applicable)
            if progressState.showProgressBar {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                        Rectangle()
                            .fill(progressState.barFillColor)
                            .frame(width: geometry.size.width * progressState.progressBarRatio)
                            .animation(.easeInOut(duration: 0.3), value: progressState.progressBarRatio)
                    }
                }
                .frame(height: 4)
                .clipShape(Capsule())
            }
        }
        .listRowSeparator(.hidden)
        .padding(.vertical, 10)
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
    
    var body: some View {
        ForEach(dayGroups, id: \.date) { dayGroup in
            Section {
                ForEach(dayGroup.sets, id: \.persistentModelID) { set in
                    HStack {
                        Text("\(Formatters.formatWeight(set.weight)) kg × \(set.reps)")
                            .monospacedDigit()
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text(set.timestamp.formatted(
                                Date.FormatStyle()
                                    .hour().minute()
                                    .locale(Locale(identifier: "en_GB_POSIX"))
                            ))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            
                            // Add repeat button only for most recent set overall
                            if isMostRecentSet(set, sets) {
                                Button {
                                    repeatSet(set)
                                } label: {
                                    Image(systemName: "arrow.clockwise.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(.tint)
                                }
                                .buttonStyle(.plain)
                                .contentShape(Rectangle())
                            }
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