//
//  AddSetView.swift
//  PlainWeights
//
//  Created by Assistant on 2025-09-22.
//

import SwiftUI
import SwiftData

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
                // Input fields container - matching ExerciseSummaryView style
                VStack(spacing: 16) {
                    // Weight input box
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Weight (kg)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("Enter weight (optional)", text: $weightText)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .weight)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .reps
                            }
                            .padding(12)
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
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("Enter reps (optional)", text: $repsText)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .reps)
                            .submitLabel(.done)
                            .onSubmit {
                                focusedField = nil
                            }
                            .padding(12)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(focusedField == .reps ? Color.blue : Color.gray.opacity(0.3), lineWidth: focusedField == .reps ? 2 : 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(16)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )

                // Warm-up toggle
                HStack {
                    Text("Warm-up set")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Toggle("", isOn: $isWarmUpSet)
                        .labelsHidden()
                        .tint(isWarmUpSet ? Color(red: 0.7, green: 0.1, blue: 0.1) : .blue)
                }
                .padding(.horizontal, 16)

                // Drop set toggle
                HStack {
                    Text("Drop set")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Toggle("", isOn: $isDropSet)
                        .labelsHidden()
                        .tint(isDropSet ? .teal : .blue)
                }
                .padding(.horizontal, 16)

                // Pause at top toggle
                HStack {
                    Text("Pause at top")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Toggle("", isOn: $isPauseAtTop)
                        .labelsHidden()
                        .tint(isPauseAtTop ? .pink : .blue)
                }
                .padding(.horizontal, 16)

                // Add Set button - matching ExerciseDetailView design
                HStack {
                    Spacer()
                    Button(action: addSet) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                                .font(.caption)
                            Text("Add Set")
                                .font(.caption.bold())
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(canAddSet ? Color.blue : Color.gray)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .disabled(!canAddSet)
                }

                Spacer()
            }
            .padding(16)
            .background(AnimatedGradientBackground())
            .navigationTitle("Add Set")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
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
