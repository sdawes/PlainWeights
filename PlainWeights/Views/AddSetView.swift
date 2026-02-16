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
    case warmup = "Warm-up"
    case dropset = "Drop"
    case assisted = "Assisted"
    case toFailure = "To Failure"
    case pause = "Pause"
    case timed = "Timed"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .warmup: return "flame.fill"
        case .dropset: return "chevron.down.2"
        case .assisted: return "hand.raised.fill"
        case .toFailure: return "bolt.fill"
        case .pause: return "pause.fill"
        case .timed: return "timer"
        }
    }

    var accentColor: Color {
        switch self {
        case .warmup: return AppTheme.warmUpColor
        case .dropset: return AppTheme.dropSetColor
        case .assisted: return AppTheme.assistedColor
        case .toFailure: return AppTheme.failureColor
        case .pause: return AppTheme.pauseAtTopColor
        case .timed: return AppTheme.timedSetColor
        }
    }
}

// MARK: - Set Type Pill Selector

struct SetTypePillSelector: View {
    @Environment(ThemeManager.self) private var themeManager
    @Binding var selectedType: SetTypeOption?

    // 6 special set types in 3 rows of 2
    private let gridRows: [[SetTypeOption]] = [
        [.warmup, .toFailure],
        [.dropset, .assisted],
        [.pause, .timed]
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Set Type")
                .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)

            VStack(spacing: 8) {
                ForEach(gridRows, id: \.first) { row in
                    HStack(spacing: 8) {
                        ForEach(row) { type in
                            setTypePill(for: type)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func setTypePill(for type: SetTypeOption) -> some View {
        let isSelected = selectedType == type
        // Use white text/icon for most colors, black for light backgrounds like orange
        let selectedForeground: Color = type == .warmup ? .black : .white

        Button {
            // Toggle: tap selected to deselect, tap unselected to select
            if isSelected {
                selectedType = nil
            } else {
                selectedType = type
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 14))
                    .frame(width: 20)
                Text(type.rawValue)
                    .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(isSelected ? type.accentColor : themeManager.effectiveTheme.cardBackgroundColor)
            .foregroundStyle(isSelected ? selectedForeground : themeManager.effectiveTheme.primaryText)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? Color.clear : themeManager.effectiveTheme.borderColor,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
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
    @State private var selectedType: SetTypeOption? = nil
    @State private var hasConvertedInitialWeight = false
    @FocusState private var focusedField: Field?
    @AppStorage("lastEditedSetField") private var lastEditedField: String = "weight"

    enum Field: String {
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

    private static func typeFromSet(_ set: ExerciseSet) -> SetTypeOption? {
        if set.isWarmUp { return .warmup }
        if set.isToFailure { return .toFailure }
        if set.isDropSet { return .dropset }
        if set.isAssisted { return .assisted }
        if set.isPauseAtTop { return .pause }
        if set.isTimedSet { return .timed }
        return nil  // Normal set = no selection
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("\(setToEdit == nil ? "Add Set" : "Edit Set") - \(exercise.name)")
                    .font(themeManager.effectiveTheme.title3Font)
                    .lineLimit(1)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 16)

            // Content
            VStack(alignment: .leading, spacing: 24) {
                // Weight and Reps inputs
                HStack(spacing: 16) {
                // Weight input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight (\(themeManager.weightUnit.displayName))")
                        .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)

                    TextField("0", text: $weightText)
                        .font(themeManager.effectiveTheme.dataFont(size: 20))
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .weight)
                        .multilineTextAlignment(.center)
                        .padding(16)
                        .frame(height: 56)
                        .background(themeManager.effectiveTheme.cardBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    focusedField == .weight ? themeManager.effectiveTheme.primaryText : themeManager.effectiveTheme.borderColor,
                                    lineWidth: focusedField == .weight ? 2 : 1
                                )
                        )
                        .onChange(of: weightText) { _, newValue in
                            // Allow only digits and one decimal point, max 6 chars (e.g., "100.25")
                            let filtered = newValue.filter { $0.isNumber || $0 == "." }
                            let limited = String(filtered.prefix(6))
                            // Ensure only one decimal point
                            let parts = limited.split(separator: ".", omittingEmptySubsequences: false)
                            if parts.count > 2 {
                                weightText = String(parts[0]) + "." + String(parts[1])
                            } else if limited != newValue {
                                weightText = limited
                            }
                        }
                }

                // Reps input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reps")
                        .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)

                    TextField("0", text: $repsText)
                        .font(themeManager.effectiveTheme.dataFont(size: 20))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .reps)
                        .multilineTextAlignment(.center)
                        .padding(16)
                        .frame(height: 56)
                        .background(themeManager.effectiveTheme.cardBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    focusedField == .reps ? themeManager.effectiveTheme.primaryText : themeManager.effectiveTheme.borderColor,
                                    lineWidth: focusedField == .reps ? 2 : 1
                                )
                        )
                        .onChange(of: repsText) { _, newValue in
                            // Allow only digits, max 3 chars
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue || filtered.count > 3 {
                                repsText = String(filtered.prefix(3))
                            }
                        }
                }
            }

            // Set Type selector
            SetTypePillSelector(selectedType: $selectedType)

            // Save button
            Button(action: addSet) {
                Text(setToEdit == nil ? "Save Set" : "Update Set")
                    .font(themeManager.effectiveTheme.headlineFont)
                    .foregroundStyle(themeManager.effectiveTheme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canAddSet ? themeManager.effectiveTheme.primary : themeManager.effectiveTheme.primary.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(!canAddSet)
            }
            .padding(.top, 24)

            Spacer()
        }
        .padding(24)
        .background(themeManager.effectiveTheme.background)
        .onAppear {
            // Convert initial weight from kg to display unit (only once)
            if !hasConvertedInitialWeight {
                if let kgValue = Double(weightText), kgValue > 0 {
                    let displayValue = themeManager.displayWeight(kgValue)
                    weightText = Formatters.formatWeight(displayValue)
                }
                hasConvertedInitialWeight = true
            }
            // Focus the last edited field
            focusedField = Field(rawValue: lastEditedField) ?? .weight
        }
        .onChange(of: focusedField) { _, newValue in
            if let field = newValue {
                // Remember which field was focused
                lastEditedField = field.rawValue
                // Select all text in the field
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(50))
                    UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                }
            }
        }
    }

    // MARK: - Business Logic

    private var canAddSet: Bool {
        ExerciseSetService.validateInput(weightText: weightText, repsText: repsText) != nil
    }

    private func addSet() {
        guard let (displayWeight, reps) = ExerciseSetService.validateInput(
            weightText: weightText,
            repsText: repsText
        ) else {
            return
        }

        // Convert display weight back to kg for storage
        let weight = themeManager.toKg(displayWeight)

        // Convert selectedType to boolean flags
        let isWarmUp = selectedType == .warmup
        let isDropSet = selectedType == .dropset
        let isAssisted = selectedType == .assisted
        let isPauseAtTop = selectedType == .pause
        let isTimedSet = selectedType == .timed
        let isToFailure = selectedType == .toFailure

        do {
            if let setToEdit = setToEdit {
                // Update existing set
                try ExerciseSetService.updateSet(
                    setToEdit,
                    weight: weight,
                    reps: reps,
                    isWarmUp: isWarmUp,
                    isDropSet: isDropSet,
                    isAssisted: isAssisted,
                    isPauseAtTop: isPauseAtTop,
                    isTimedSet: isTimedSet,
                    tempoSeconds: 0,
                    isToFailure: isToFailure,
                    context: context
                )
            } else {
                // Add new set
                try ExerciseSetService.addSet(
                    weight: weight,
                    reps: reps,
                    isWarmUp: isWarmUp,
                    isDropSet: isDropSet,
                    isAssisted: isAssisted,
                    isPauseAtTop: isPauseAtTop,
                    isTimedSet: isTimedSet,
                    tempoSeconds: 0,
                    isToFailure: isToFailure,
                    to: exercise,
                    context: context
                )
            }
            dismiss()
        } catch { }
    }
}
