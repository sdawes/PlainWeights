//
//  AddExerciseView.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 16/08/2025.
//

import SwiftUI
import SwiftData

struct AddExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category = ""

    // Callback to notify parent when exercise is created
    let onExerciseCreated: ((Exercise) -> Void)?

    init(onExerciseCreated: ((Exercise) -> Void)? = nil) {
        self.onExerciseCreated = onExerciseCreated
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Exercise Name", text: $name)
                TextField("Category", text: $category)
            }
            .navigationTitle("Add Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newExercise = Exercise(name: name, category: category)
                        modelContext.insert(newExercise)
                        try? modelContext.save()
                        dismiss()

                        // Call callback with newly created exercise
                        onExerciseCreated?(newExercise)
                    }
                    .disabled(name.isEmpty || category.isEmpty)
                }
            }
        }
    }
}