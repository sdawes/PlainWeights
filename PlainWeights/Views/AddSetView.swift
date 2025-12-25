//
//  AddSetView.swift
//  PlainWeights
//
//  Created by Assistant on 2025-09-22.
//

import SwiftUI
import SwiftData

// MARK: - Weight and Reps Input Container

struct WeightRepsInputContainer: View {
    @Binding var weightText: String
    @Binding var repsText: String
    @FocusState.Binding var focusedField: AddSetView.Field?

    var body: some View {
        HStack(spacing: 12) {
            // Weight input box
            VStack(alignment: .leading, spacing: 6) {
                Text("Weight (kg)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("Enter weight (optional)", text: $weightText)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .weight)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .reps
                    }
                    .padding(16)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(focusedField == .weight ? Color.blue : Color.gray.opacity(0.3), lineWidth: focusedField == .weight ? 2 : 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Reps input box
            VStack(alignment: .leading, spacing: 6) {
                Text("Reps")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("Enter reps (optional)", text: $repsText)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .reps)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
                    .padding(16)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(focusedField == .reps ? Color.blue : Color.gray.opacity(0.3), lineWidth: focusedField == .reps ? 2 : 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Set Options Chips

struct SetOptionsToggles: View {
    @Binding var isWarmUpSet: Bool
    @Binding var isDropSet: Bool
    @Binding var isPauseAtTop: Bool
    @Binding var isTimedSet: Bool

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            // Row 1
            chipButton(icon: "flame.fill", text: "Warm-up",
                       isSelected: isWarmUpSet, activeColor: .orange) {
                selectOption(warmUp: true)
            }
            chipButton(icon: "chevron.down", text: "Drop set",
                       isSelected: isDropSet, activeColor: .teal) {
                selectOption(dropSet: true)
            }
            // Row 2
            chipButton(icon: "pause.fill", text: "Pause",
                       isSelected: isPauseAtTop, activeColor: .pink) {
                selectOption(pause: true)
            }
            chipButton(icon: "timer", text: "Timed",
                       isSelected: isTimedSet, activeColor: .black) {
                selectOption(timed: true)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func chipButton(icon: String, text: String, isSelected: Bool,
                            activeColor: Color, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(text)
                    .font(.subheadline)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(isSelected ? activeColor : Color(.systemGray5))
            .foregroundStyle(isSelected ? .white : .secondary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Selection Logic

    private func selectOption(warmUp: Bool = false, dropSet: Bool = false,
                              pause: Bool = false, timed: Bool = false) {
        // Toggle behavior: tap selected to deselect, tap unselected to select (and deselect others)
        if warmUp {
            if isWarmUpSet {
                isWarmUpSet = false
            } else {
                isWarmUpSet = true
                isDropSet = false
                isPauseAtTop = false
                isTimedSet = false
            }
        } else if dropSet {
            if isDropSet {
                isDropSet = false
            } else {
                isDropSet = true
                isWarmUpSet = false
                isPauseAtTop = false
                isTimedSet = false
            }
        } else if pause {
            if isPauseAtTop {
                isPauseAtTop = false
            } else {
                isPauseAtTop = true
                isWarmUpSet = false
                isDropSet = false
                isTimedSet = false
            }
        } else if timed {
            if isTimedSet {
                isTimedSet = false
            } else {
                isTimedSet = true
                isWarmUpSet = false
                isDropSet = false
                isPauseAtTop = false
            }
        }
    }
}

// MARK: - Add Set Button

struct AddSetButton: View {
    let action: () -> Void
    let isEnabled: Bool
    let title: String
    let iconName: String

    init(action: @escaping () -> Void, isEnabled: Bool, title: String = "Add Set", iconName: String = "plus.circle.fill") {
        self.action = action
        self.isEnabled = isEnabled
        self.title = title
        self.iconName = iconName
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.body)
                Text(title)
                    .font(.body.bold())
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isEnabled ? Color.blue : Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .disabled(!isEnabled)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Main Add Set View

struct AddSetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    let exercise: Exercise
    let setToEdit: ExerciseSet?

    @State private var weightText = ""
    @State private var repsText = ""
    @State private var isWarmUpSet = false
    @State private var isDropSet = false
    @State private var isPauseAtTop = false
    @State private var isTimedSet = false
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
            _isWarmUpSet = State(initialValue: set.isWarmUp)
            _isDropSet = State(initialValue: set.isDropSet)
            _isPauseAtTop = State(initialValue: set.isPauseAtTop)
            _isTimedSet = State(initialValue: set.isTimedSet)
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

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Weight and reps input container
                WeightRepsInputContainer(
                    weightText: $weightText,
                    repsText: $repsText,
                    focusedField: $focusedField
                )

                // Set options toggles
                SetOptionsToggles(
                    isWarmUpSet: $isWarmUpSet,
                    isDropSet: $isDropSet,
                    isPauseAtTop: $isPauseAtTop,
                    isTimedSet: $isTimedSet
                )

                // Add/Update Set button (moved up from bottom)
                AddSetButton(
                    action: addSet,
                    isEnabled: canAddSet,
                    title: setToEdit == nil ? "Add Set" : "Update Set",
                    iconName: setToEdit == nil ? "plus.circle.fill" : "checkmark.circle.fill"
                )
                .padding(.top, 8)

                Spacer()
            }
            .padding(16)
            .background(Color.white)
            .navigationTitle(setToEdit == nil ? "Add Set" : "Edit Set")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        addSet()
                    }
                    .disabled(!canAddSet)
                }
            }
            .onAppear {
                focusedField = .weight
            }
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

        do {
            if let setToEdit = setToEdit {
                // Update existing set
                try ExerciseSetService.updateSet(
                    setToEdit,
                    weight: weight,
                    reps: reps,
                    isWarmUp: isWarmUpSet,
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
                    isWarmUp: isWarmUpSet,
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
