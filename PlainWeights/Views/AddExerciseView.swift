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
    @Environment(ThemeManager.self) private var themeManager

    @State private var name = ""
    @State private var tags: [String] = []
    @State private var tagInput = ""
    @FocusState private var tagFieldFocused: Bool

    // Optional exercise for edit mode
    let exerciseToEdit: Exercise?

    // Callback to notify parent when exercise is created (only used in create mode)
    let onExerciseCreated: ((Exercise) -> Void)?

    private var isEditMode: Bool { exerciseToEdit != nil }
    private var navigationTitle: String { isEditMode ? "Edit Exercise" : "Add Exercise" }

    init(exerciseToEdit: Exercise? = nil, onExerciseCreated: ((Exercise) -> Void)? = nil) {
        self.exerciseToEdit = exerciseToEdit
        self.onExerciseCreated = onExerciseCreated

        // Initialize state from exercise if editing
        if let exercise = exerciseToEdit {
            _name = State(initialValue: exercise.name)
            _tags = State(initialValue: exercise.tags)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Exercise Name", text: $name)
                        .font(.jetBrainsMono(.body))
                        .listRowBackground(
                            themeManager.currentTheme == .dark ? Color.clear : Color(.systemBackground)
                        )

                    VStack(alignment: .leading, spacing: 8) {
                        // Display existing tags as pills
                        if !tags.isEmpty {
                            FlowLayout(spacing: 6) {
                                ForEach(tags, id: \.self) { tag in
                                    TagPillView(tag: tag) {
                                        withAnimation {
                                            tags.removeAll { $0 == tag }
                                        }
                                    }
                                }
                            }
                        }

                        // Tag input field
                        TextField("Add tags (space or enter to add)", text: $tagInput)
                            .font(.jetBrainsMono(.body))
                            .focused($tagFieldFocused)
                            .onChange(of: tagInput) { _, newValue in
                                // When space is typed, convert text to tag
                                if newValue.hasSuffix(" ") {
                                    let trimmed = newValue.trimmingCharacters(in: .whitespaces).lowercased()
                                    if !trimmed.isEmpty && !tags.contains(trimmed) {
                                        withAnimation {
                                            tags.append(trimmed)
                                        }
                                    }
                                    tagInput = ""
                                }
                            }
                            .onSubmit {
                                // When enter is pressed, convert text to tag
                                let trimmed = tagInput.trimmingCharacters(in: .whitespaces).lowercased()
                                if !trimmed.isEmpty && !tags.contains(trimmed) {
                                    withAnimation {
                                        tags.append(trimmed)
                                    }
                                }
                                tagInput = ""
                                // Keep focus on tag field for continuous entry
                                tagFieldFocused = true
                            }
                    }
                    .listRowBackground(
                        themeManager.currentTheme == .dark ? Color.clear : Color(.systemBackground)
                    )
                }
            }
            .scrollContentBackground(.hidden)
            .background(AnimatedGradientBackground())
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(navigationTitle)
                        .font(.jetBrainsMono(.headline))
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Include any text still in the input field as a tag
                        var finalTags = tags
                        let trimmedInput = tagInput.trimmingCharacters(in: .whitespaces).lowercased()
                        if !trimmedInput.isEmpty && !finalTags.contains(trimmedInput) {
                            finalTags.append(trimmedInput)
                        }

                        if let exercise = exerciseToEdit {
                            // Edit mode: update existing exercise
                            exercise.name = name
                            exercise.setTags(finalTags)
                            exercise.bumpUpdated()
                        } else {
                            // Create mode: insert new exercise
                            let newExercise = Exercise(name: name, tags: finalTags)
                            modelContext.insert(newExercise)
                            onExerciseCreated?(newExercise)
                        }

                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}