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
    @FocusState private var focusedField: Field?

    enum Field {
        case weight, reps
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

                        TextField("Enter weight", text: $weightText)
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

                        TextField("Enter reps", text: $repsText)
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

                // Add Set button
                Button(action: addSet) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Set")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(canAddSet ? Color.blue : Color.gray)
                    .padding(.vertical, 12)
                }
                .disabled(!canAddSet)

                Spacer()
            }
            .padding(16)
            .navigationTitle("Add Set")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
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
                to: exercise,
                context: context
            )
            dismiss()
        } catch {
            print("Error adding set: \(error)")
        }
    }
}