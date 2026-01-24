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
    @Environment(ThemeManager.self) private var themeManager
    @Binding var weightText: String
    @Binding var repsText: String
    @FocusState.Binding var focusedField: AddSetView.Field?

    var body: some View {
        HStack(spacing: 12) {
            // Weight input box
            VStack(alignment: .leading, spacing: 6) {
                Text("Weight (kg)")
                    .font(.appFont(.subheadline))
                    .foregroundStyle(.secondary)

                TextField("Enter weight (optional)", text: $weightText)
                    .font(.appFont(.body))
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .weight)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .reps
                    }
                    .padding(16)
                    .background(themeManager.currentTheme == .dark ? Color.clear : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(focusedField == .weight ? Color.blue : themeManager.currentTheme.borderColor, lineWidth: focusedField == .weight ? 2 : 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Reps input box
            VStack(alignment: .leading, spacing: 6) {
                Text("Reps")
                    .font(.appFont(.subheadline))
                    .foregroundStyle(.secondary)

                TextField("Enter reps (optional)", text: $repsText)
                    .font(.appFont(.body))
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .reps)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
                    .padding(16)
                    .background(themeManager.currentTheme == .dark ? Color.clear : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(focusedField == .reps ? Color.blue : themeManager.currentTheme.borderColor, lineWidth: focusedField == .reps ? 2 : 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(16)
        .background(themeManager.currentTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(themeManager.currentTheme.borderColor, lineWidth: 1)
        )
    }
}

// MARK: - Set Options Chips

struct SetOptionsToggles: View {
    @Environment(ThemeManager.self) private var themeManager
    @Binding var isWarmUpSet: Bool
    @Binding var isBonusSet: Bool
    @Binding var isDropSet: Bool
    @Binding var isPauseAtTop: Bool
    @Binding var isTimedSet: Bool

    @State private var showMaxWarning = false

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    // Count of currently selected options (max 2 allowed)
    private var selectedCount: Int {
        [isWarmUpSet, isBonusSet, isDropSet, isPauseAtTop, isTimedSet]
            .filter { $0 }.count
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            // Row 1
            chipButton(icon: "flame.fill", text: "Warm-up",
                       isSelected: isWarmUpSet, activeColor: .orange) {
                toggleOption(&isWarmUpSet)
            }
            chipButton(icon: "chevron.down", text: "Drop set",
                       isSelected: isDropSet, activeColor: .teal) {
                toggleOption(&isDropSet)
            }
            // Row 2
            chipButton(icon: "pause.fill", text: "Pause",
                       isSelected: isPauseAtTop, activeColor: .pink) {
                toggleOption(&isPauseAtTop)
            }
            chipButton(icon: "timer", text: "Timed",
                       isSelected: isTimedSet, activeColor: .black) {
                toggleOption(&isTimedSet)
            }
            // Row 3
            chipButton(icon: "star.fill", text: "Bonus",
                       isSelected: isBonusSet, activeColor: .yellow) {
                toggleOption(&isBonusSet)
            }
            Color.clear // Empty cell
        }
        .padding(12)
        .background(themeManager.currentTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(themeManager.currentTheme.borderColor, lineWidth: 1)
        )
        .alert("Maximum 2 options", isPresented: $showMaxWarning) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please deselect an option before adding another.")
        }
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
                    .font(.appFont(size: 12))
                Text(text)
                    .font(.appFont(.subheadline))
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(isSelected ? activeColor : Color.clear)
            .foregroundStyle(isSelected ? .white : .secondary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    .foregroundStyle(isSelected ? Color.clear : themeManager.currentTheme.borderColor)
            )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Selection Logic

    private func toggleOption(_ option: inout Bool) {
        if option {
            // Always allow deselecting
            option = false
        } else if selectedCount < 2 {
            // Allow selecting if under limit
            option = true
        } else {
            // Show warning for 3rd selection attempt
            showMaxWarning = true
        }
    }
}

// MARK: - Add Set Button

struct AddSetButton: View {
    @Environment(ThemeManager.self) private var themeManager
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
                    .font(.appFont(.headline))
                Text(title)
                    .font(.appFont(.headline))
            }
            .foregroundStyle(isEnabled ? themeManager.currentTheme.textColor : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    .foregroundStyle(isEnabled ? themeManager.currentTheme.textColor : .gray)
            )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 10))
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
    @State private var isBonusSet = false
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
            _isBonusSet = State(initialValue: set.isBonus)
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
                    isBonusSet: $isBonusSet,
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
            .background(AnimatedGradientBackground())
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
                    isBonus: isBonusSet,
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
                    isBonus: isBonusSet,
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
