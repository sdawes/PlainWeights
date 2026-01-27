//
//  AddSetView.swift
//  PlainWeights
//
//  Created by Assistant on 2025-09-22.
//

import SwiftUI
import SwiftData

// MARK: - Set Type Enum for UI

enum SetTypeOption: String, CaseIterable, Identifiable {
    case normal = "Normal"
    case warmup = "Warm-up"
    case dropset = "Drop Set"
    case bonus = "Bonus"
    case pause = "Pause Rep"
    case timed = "Timed"

    var id: String { rawValue }
}

// MARK: - Set Type Pill Selector

struct SetTypePillSelector: View {
    @Environment(ThemeManager.self) private var themeManager
    @Binding var selectedType: SetTypeOption

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Set Type")
                .font(themeManager.currentTheme.subheadlineFont)
                .foregroundStyle(themeManager.currentTheme.mutedForeground)

            FlowLayout(spacing: 8) {
                ForEach(SetTypeOption.allCases) { type in
                    Button {
                        selectedType = type
                    } label: {
                        Text(type.rawValue)
                            .font(themeManager.currentTheme.subheadlineFont)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedType == type ? themeManager.currentTheme.primary : themeManager.currentTheme.muted)
                            .foregroundStyle(selectedType == type ? .white : themeManager.currentTheme.primaryText)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Main Add Set View

struct AddSetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(ThemeManager.self) private var themeManager
    let exercise: Exercise
    let setToEdit: ExerciseSet?

    @State private var weightText = ""
    @State private var repsText = ""
    @State private var selectedType: SetTypeOption = .normal
    @FocusState private var focusedField: Field?

    enum Field {
        case weight, reps
    }

    init(exercise: Exercise, initialWeight: Double? = nil, initialReps: Int? = nil, setToEdit: ExerciseSet? = nil) {
        self.exercise = exercise
        self.setToEdit = setToEdit

        // If editing, pre-populate all fields from the set
        if let set = setToEdit {
            _weightText = State(initialValue: Formatters.formatWeight(set.weight))
            _repsText = State(initialValue: String(set.reps))
            _selectedType = State(initialValue: Self.typeFromSet(set))
        } else {
            // If adding new set, use initial values
            if let initialWeight = initialWeight, initialWeight >= 0 {
                _weightText = State(initialValue: Formatters.formatWeight(initialWeight))
            }
            if let initialReps = initialReps, initialReps >= 0 {
                _repsText = State(initialValue: String(initialReps))
            }
        }
    }

    private static func typeFromSet(_ set: ExerciseSet) -> SetTypeOption {
        if set.isWarmUp { return .warmup }
        if set.isBonus { return .bonus }
        if set.isDropSet { return .dropset }
        if set.isPauseAtTop { return .pause }
        if set.isTimedSet { return .timed }
        return .normal
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            HStack {
                Text("\(setToEdit == nil ? "Add Set" : "Edit Set") - \(exercise.name)")
                    .font(themeManager.currentTheme.title3Font)
                    .lineLimit(1)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(themeManager.currentTheme.mutedForeground)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 8)

            // Weight and Reps inputs
            HStack(spacing: 16) {
                // Weight input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight (kg)")
                        .font(themeManager.currentTheme.subheadlineFont)
                        .foregroundStyle(themeManager.currentTheme.mutedForeground)

                    TextField("0", text: $weightText)
                        .font(themeManager.currentTheme.dataFont(size: 20))
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .weight)
                        .padding(16)
                        .background(themeManager.currentTheme.muted)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Reps input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reps")
                        .font(themeManager.currentTheme.subheadlineFont)
                        .foregroundStyle(themeManager.currentTheme.mutedForeground)

                    TextField("0", text: $repsText)
                        .font(themeManager.currentTheme.dataFont(size: 20))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .reps)
                        .padding(16)
                        .background(themeManager.currentTheme.muted)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            // Set Type selector
            SetTypePillSelector(selectedType: $selectedType)

            // Save button
            Button(action: addSet) {
                Text(setToEdit == nil ? "Save Set" : "Update Set")
                    .font(themeManager.currentTheme.headlineFont)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canAddSet ? themeManager.currentTheme.primary : themeManager.currentTheme.primary.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(!canAddSet)

            Spacer()
        }
        .padding(24)
        .background(themeManager.currentTheme.background)
        .onAppear {
            focusedField = .weight
        }
    }

    // MARK: - Business Logic

    private var canAddSet: Bool {
        ExerciseSetService.validateInput(weightText: weightText, repsText: repsText) != nil
    }

    private func addSet() {
        guard let (weight, reps) = ExerciseSetService.validateInput(
            weightText: weightText,
            repsText: repsText
        ) else {
            return
        }

        // Convert selectedType to boolean flags
        let isWarmUp = selectedType == .warmup
        let isBonus = selectedType == .bonus
        let isDropSet = selectedType == .dropset
        let isPauseAtTop = selectedType == .pause
        let isTimedSet = selectedType == .timed

        do {
            if let setToEdit = setToEdit {
                // Update existing set
                try ExerciseSetService.updateSet(
                    setToEdit,
                    weight: weight,
                    reps: reps,
                    isWarmUp: isWarmUp,
                    isBonus: isBonus,
                    isDropSet: isDropSet,
                    isPauseAtTop: isPauseAtTop,
                    isTimedSet: isTimedSet,
                    tempoSeconds: 0,
                    context: context
                )
            } else {
                // Add new set
                try ExerciseSetService.addSet(
                    weight: weight,
                    reps: reps,
                    isWarmUp: isWarmUp,
                    isBonus: isBonus,
                    isDropSet: isDropSet,
                    isPauseAtTop: isPauseAtTop,
                    isTimedSet: isTimedSet,
                    tempoSeconds: 0,
                    to: exercise,
                    context: context
                )
            }
            dismiss()
        } catch {
            print("Error \(setToEdit == nil ? "adding" : "updating") set: \(error)")
        }
    }
}
