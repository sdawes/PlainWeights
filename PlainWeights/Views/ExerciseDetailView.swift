//
//  ExerciseDetailViewV2.swift
//  PlainWeights
//
//  Created for testing new design approach
//

import SwiftUI
import SwiftData

// MARK: - MetricCard Component

struct MetricCard: View {
    let label: String
    let value: String
    let unit: String
    let changeAmount: String?
    let changeDirection: ProgressTracker.PRDirection?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            Text(label.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)

            // Main value
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(unit)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            // Change indicator
            if let changeAmount = changeAmount, let direction = changeDirection {
                HStack(spacing: 4) {
                    Image(systemName: direction.iconName)
                        .font(.caption2)
                        .foregroundStyle(direction.color)
                    Text(changeAmount)
                        .font(.caption)
                        .foregroundStyle(direction.color)
                }
            } else {
                // Placeholder for alignment when no change
                Text("—")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 110)
        .padding(16)
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

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
    @FocusState private var notesFocused: Bool
    @State private var showingDeleteAlert = false

    // Cached data for performance
    @State private var todaySets: [ExerciseSet] = []
    @State private var historicDayGroups: [ExerciseDataGrouper.DayGroup] = []

    // Cached progress state
    private var progressState: ProgressTracker.ProgressState? {
        ProgressTracker.createProgressState(from: sets)
    }

    // Volume direction indicator (reused from View 1)
    private var volumeDirection: ProgressTracker.PRDirection {
        guard let state = progressState else { return .same }
        return ProgressTracker.volumeComparisonDirection(
            today: state.todayVolume,
            last: state.lastCompletedDayInfo?.volume ?? 0
        )
    }

    // Volume difference calculation (reused from View 1)
    private var volumeDifference: (amount: Double, label: String)? {
        guard let state = progressState, state.todayVolume > 0 else { return nil }

        let lastVolume = state.lastCompletedDayInfo?.volume ?? 0
        let diff = state.todayVolume - lastVolume

        if diff > 0 {
            return (diff, "more")
        } else if diff < 0 {
            return (abs(diff), "left")
        }
        return nil // Equal, no message
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
            .padding(.bottom, 0)

            // Metrics container section
            Section {
                // White container with metric cards and buttons
                VStack(alignment: .leading, spacing: 16) {
                    // Three metric cards
                    HStack(spacing: 12) {
                        // Card 1: Weight
                        MetricCard(
                            label: "Weight",
                            value: formatWeight(),
                            unit: "kg",
                            changeAmount: formatWeightChange(),
                            changeDirection: progressState?.personalRecords?.weightDirection
                        )

                        // Card 2: Reps
                        MetricCard(
                            label: "Reps",
                            value: formatReps(),
                            unit: "",
                            changeAmount: formatRepsChange(),
                            changeDirection: progressState?.personalRecords?.repsDirection
                        )

                        // Card 3: Volume
                        MetricCard(
                            label: "Volume",
                            value: formatVolume(),
                            unit: "kg",
                            changeAmount: formatVolumeChange(),
                            changeDirection: volumeDirection
                        )
                    }

                    // Progress bar
                    VStack(alignment: .leading, spacing: 8) {
                        // Thin progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track (grey)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(height: 4)

                                // Fill (blue/green based on progress)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(progressState?.barFillColor ?? .blue)
                                    .frame(width: geometry.size.width * progressBarRatio, height: 4)
                            }
                        }
                        .frame(height: 4)

                        // Label: "Today X/Y kg"
                        Text("Today \(formatTodayVolume())/\(formatLastVolume()) kg")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Action button
                    HStack(spacing: 8) {
                        Spacer()

                        // Add Set button (with previous values pre-filled)
                        Button(action: {
                            addSetConfig = .previous(
                                exercise: exercise,
                                weight: lastWorkingSetValues.weight,
                                reps: lastWorkingSetValues.reps
                            )
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.body)
                                    .foregroundStyle(.blue)
                                Text("Add Set")
                                    .foregroundStyle(.black)
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.regular)
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0))

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
        .listStyle(.insetGrouped)
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

    // MARK: - Formatting Helpers

    private func formatWeight() -> String {
        guard let lastInfo = progressState?.lastCompletedDayInfo else {
            return "0"
        }
        return Formatters.formatWeight(lastInfo.maxWeight)
    }

    private func formatReps() -> String {
        guard let lastInfo = progressState?.lastCompletedDayInfo else {
            return "0"
        }
        return "\(lastInfo.maxWeightReps)"
    }

    private func formatVolume() -> String {
        guard let lastInfo = progressState?.lastCompletedDayInfo else {
            return "0"
        }
        return Formatters.formatVolume(lastInfo.volume)
    }

    private func formatWeightChange() -> String? {
        guard let pr = progressState?.personalRecords else {
            return nil
        }
        return "\(Formatters.formatWeight(abs(pr.weightImprovement))) kg"
    }

    private func formatRepsChange() -> String? {
        guard let pr = progressState?.personalRecords else {
            return nil
        }
        let amount = abs(pr.repsImprovement)
        let repsText = amount == 1 ? "rep" : "reps"
        return "\(amount) \(repsText)"
    }

    private func formatVolumeChange() -> String? {
        guard let diff = volumeDifference else {
            // When equal (no difference), show "0 kg"
            guard let state = progressState, state.todayVolume > 0 else {
                return nil
            }
            let lastVolume = state.lastCompletedDayInfo?.volume ?? 0
            if state.todayVolume == lastVolume {
                return "0 kg"
            }
            return nil
        }
        return "\(Formatters.formatVolume(diff.amount)) kg"
    }

    /// Get the weight and reps values from the last working (non-warm-up) set
    private var lastWorkingSetValues: (weight: Double?, reps: Int?) {
        guard let lastWorkingSet = sets.first(where: { !$0.isWarmUp }) else {
            return (nil, nil)
        }
        return (lastWorkingSet.weight, lastWorkingSet.reps)
    }

    // MARK: - Progress Bar Helpers

    private var progressBarRatio: CGFloat {
        guard let state = progressState else { return 0 }
        return CGFloat(state.progressBarRatio)
    }

    private func formatTodayVolume() -> String {
        guard let state = progressState else { return "0" }
        return Formatters.formatVolume(state.todayVolume)
    }

    private func formatLastVolume() -> String {
        guard let lastVolume = progressState?.lastCompletedDayInfo?.volume else {
            return "0"
        }
        return Formatters.formatVolume(lastVolume)
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
