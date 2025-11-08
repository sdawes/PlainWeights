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

// MARK: - Set Options Toggles

struct SetOptionsToggles: View {
    @Binding var isWarmUpSet: Bool
    @Binding var isDropSet: Bool
    @Binding var isPauseAtTop: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Warm-up toggle
            HStack(spacing: 10) {
                Circle()
                    .fill(isWarmUpSet ? .orange : .secondary)
                    .frame(width: 20, height: 20)
                    .overlay {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.white)
                    }

                Text("Warm-up set")
                    .font(.subheadline)
                    .foregroundStyle(isWarmUpSet ? .primary : .secondary)

                Spacer()

                Toggle("", isOn: $isWarmUpSet)
                    .labelsHidden()
                    .tint(isWarmUpSet ? Color(red: 0.7, green: 0.1, blue: 0.1) : .blue)
            }

            // Drop set toggle
            HStack(spacing: 10) {
                Circle()
                    .fill(isDropSet ? .teal : .secondary)
                    .frame(width: 20, height: 20)
                    .overlay {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundStyle(.white)
                    }

                Text("Drop set")
                    .font(.subheadline)
                    .foregroundStyle(isDropSet ? .primary : .secondary)

                Spacer()

                Toggle("", isOn: $isDropSet)
                    .labelsHidden()
                    .tint(isDropSet ? .teal : .blue)
            }

            // Pause at top toggle
            HStack(spacing: 10) {
                Circle()
                    .fill(isPauseAtTop ? .pink : .secondary)
                    .frame(width: 20, height: 20)
                    .overlay {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.white)
                    }

                Text("Pause at top")
                    .font(.subheadline)
                    .foregroundStyle(isPauseAtTop ? .primary : .secondary)

                Spacer()

                Toggle("", isOn: $isPauseAtTop)
                    .labelsHidden()
                    .tint(isPauseAtTop ? .pink : .blue)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Add Set Button

struct AddSetButton: View {
    let action: () -> Void
    let isEnabled: Bool

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.body)
                Text("Add Set")
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

    @State private var weightText = ""
    @State private var repsText = ""
    @State private var isWarmUpSet = false
    @State private var isDropSet = false
    @State private var isPauseAtTop = false
    @FocusState private var focusedField: Field?

    enum Field {
        case weight, reps
    }

    init(exercise: Exercise, initialWeight: Double? = nil, initialReps: Int? = nil) {
        self.exercise = exercise
        if let initialWeight = initialWeight, initialWeight >= 0 {
            _weightText = State(initialValue: Formatters.formatWeight(initialWeight))
        }
        if let initialReps = initialReps, initialReps >= 0 {
            _repsText = State(initialValue: String(initialReps))
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
                    isPauseAtTop: $isPauseAtTop
                )

                Spacer()
            }
            .padding(16)
            .background(Color.white)
            .navigationTitle("Add Set")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                AddSetButton(
                    action: addSet,
                    isEnabled: canAddSet
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
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
            try ExerciseSetService.addSet(
                weight: weight,
                reps: reps,
                isWarmUp: isWarmUpSet,
                isDropSet: isDropSet,
                isPauseAtTop: isPauseAtTop,
                to: exercise,
                context: context
            )
            dismiss()
        } catch {
            print("Error adding set: \(error)")
        }
    }
}
