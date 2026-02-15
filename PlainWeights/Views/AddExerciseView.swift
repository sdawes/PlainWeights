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
    @State private var secondaryTags: [String] = []
    @State private var secondaryTagInput = ""
    @State private var isDuplicateName: Bool = false
    @State private var tagSuggestions: [String] = []
    @FocusState private var nameFieldFocused: Bool
    @FocusState private var tagFieldFocused: Bool
    @FocusState private var secondaryTagFieldFocused: Bool

    // Optional exercise for edit mode
    let exerciseToEdit: Exercise?

    // Callback to notify parent when exercise is created (only used in create mode)
    let onExerciseCreated: ((Exercise) -> Void)?

    private var isEditMode: Bool { exerciseToEdit != nil }
    private var screenTitle: String { isEditMode ? "Edit Exercise" : "Add Exercise" }

    init(exerciseToEdit: Exercise? = nil, onExerciseCreated: ((Exercise) -> Void)? = nil) {
        self.exerciseToEdit = exerciseToEdit
        self.onExerciseCreated = onExerciseCreated

        // Initialize state from exercise if editing
        if let exercise = exerciseToEdit {
            _name = State(initialValue: exercise.name)
            _tags = State(initialValue: exercise.tags)
            _secondaryTags = State(initialValue: exercise.secondaryTags)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text(screenTitle)
                    .font(themeManager.effectiveTheme.title3Font)
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
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
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ExerciseNameField(
                            name: $name,
                            isFocused: $nameFieldFocused,
                            isDuplicate: isDuplicateName,
                            onSubmit: { tagFieldFocused = true }
                        )
                        .onChange(of: name) { _, _ in
                            checkForDuplicate()
                        }

                        TagInputSection(
                            title: "Primary Tags (optional)",
                            placeholder: "e.g. chest, push, strength",
                            tags: $tags,
                            input: $tagInput,
                            isFocused: $tagFieldFocused,
                            isSecondary: false,
                            suggestions: tagSuggestions,
                            onSubmit: { tagFieldFocused = true }
                        )

                        TagInputSection(
                            title: "Secondary Tags (optional)",
                            placeholder: "e.g. triceps, shoulders",
                            tags: $secondaryTags,
                            input: $secondaryTagInput,
                            isFocused: $secondaryTagFieldFocused,
                            isSecondary: true,
                            suggestions: tagSuggestions,
                            onSubmit: { secondaryTagFieldFocused = true }
                        )
                        .id("secondaryTags")
                    }
                    .padding(.top, 24)
                }
                .scrollDismissesKeyboard(.immediately)
                .onChange(of: secondaryTagFieldFocused) { _, focused in
                    if focused {
                        withAnimation { proxy.scrollTo("secondaryTags", anchor: .bottom) }
                    }
                }
                .onChange(of: secondaryTags) { _, _ in
                    if secondaryTagFieldFocused {
                        withAnimation { proxy.scrollTo("secondaryTags", anchor: .bottom) }
                    }
                }
            }

            Spacer()

            // Bottom CTA button
            Button(action: saveExercise) {
                let isDisabled = name.isEmpty || isDuplicateName
                Text(isEditMode ? "Save Changes" : "Add Exercise")
                    .font(themeManager.effectiveTheme.headlineFont)
                    .foregroundStyle(themeManager.effectiveTheme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isDisabled ? themeManager.effectiveTheme.primary.opacity(0.4) : themeManager.effectiveTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(name.isEmpty || isDuplicateName)
        }
        .padding(24)
        .background(themeManager.effectiveTheme.background)
        .onAppear {
            nameFieldFocused = true
            tagSuggestions = ExerciseService.allUniqueTags(context: modelContext)
        }
    }

    // MARK: - Actions

    private func checkForDuplicate() {
        isDuplicateName = ExerciseService.nameExists(
            name,
            excluding: exerciseToEdit,
            context: modelContext
        )
    }

    private func saveExercise() {
        // Include any text still in the input fields as tags
        var finalTags = tags
        let trimmedInput = tagInput.trimmingCharacters(in: .whitespaces).lowercased()
        if !trimmedInput.isEmpty && !finalTags.contains(trimmedInput) {
            finalTags.append(trimmedInput)
        }

        var finalSecondaryTags = secondaryTags
        let trimmedSecondaryInput = secondaryTagInput.trimmingCharacters(in: .whitespaces).lowercased()
        if !trimmedSecondaryInput.isEmpty && !finalSecondaryTags.contains(trimmedSecondaryInput) {
            finalSecondaryTags.append(trimmedSecondaryInput)
        }

        if let exercise = exerciseToEdit {
            // Edit mode: update existing exercise
            exercise.name = name
            exercise.setTags(finalTags)
            exercise.setSecondaryTags(finalSecondaryTags)
            exercise.bumpUpdated()
        } else {
            // Create mode: insert new exercise
            let newExercise = Exercise(name: name, tags: finalTags, secondaryTags: finalSecondaryTags)
            modelContext.insert(newExercise)
            onExerciseCreated?(newExercise)
        }

        try? modelContext.save()
        dismiss()
    }
}
