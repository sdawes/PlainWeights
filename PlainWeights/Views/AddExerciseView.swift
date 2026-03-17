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
    @State private var showingTagInfo = false

    // Optional exercise for edit mode
    let exerciseToEdit: Exercise?

    // Callback to notify parent when exercise is created (only used in create mode)
    let onExerciseCreated: ((Exercise) -> Void)?

    private var isEditMode: Bool { exerciseToEdit != nil }
    private var screenTitle: String { isEditMode ? "Edit Exercise" : "Add Exercise" }
    private var canSave: Bool { !name.isEmpty && !isDuplicateName }

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
            HStack(spacing: 12) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")

                Text(screenTitle)
                    .font(themeManager.effectiveTheme.title3Font)
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                    .lineLimit(1)

                Spacer()

                Button(action: saveExercise) {
                    Text("Save")
                        .font(themeManager.effectiveTheme.headlineFont)
                        .foregroundStyle(
                            canSave
                                ? themeManager.effectiveTheme.primary
                                : themeManager.effectiveTheme.primary.opacity(0.4)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
                .accessibilityLabel("Save Exercise")
            }
            .padding(.bottom, 16)

            // Content
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ExerciseNameField(
                            name: $name,
                            isFocused: $nameFieldFocused,
                            isDuplicate: isDuplicateName,
                            onSubmit: { tagFieldFocused = true }
                        )
                        .onChange(of: name) { _, _ in
                            checkForDuplicate()
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            TagInputSection(
                                title: "Primary Tags",
                                placeholder: "e.g. upper chest",
                                tags: $tags,
                                input: $tagInput,
                                isFocused: $tagFieldFocused,
                                isSecondary: false,
                                suggestions: tagSuggestions,
                                onSubmit: { tagFieldFocused = true },
                                titleAccessory: {
                                    Button {
                                        showingTagInfo = true
                                    } label: {
                                        Image(systemName: "info.circle")
                                            .font(.system(size: 12))
                                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground.opacity(0.6))
                                    }
                                    .buttonStyle(.plain)
                                    .popover(isPresented: $showingTagInfo) {
                                        tagInfoPopover
                                    }
                                }
                            )

                            TagInputSection(
                                title: "Secondary Tags",
                                placeholder: "e.g. side delts",
                                tags: $secondaryTags,
                                input: $secondaryTagInput,
                                isFocused: $secondaryTagFieldFocused,
                                isSecondary: true,
                                suggestions: tagSuggestions,
                                onSubmit: { secondaryTagFieldFocused = true }
                            )
                            .id("secondaryTags")
                        }
                    }
                    .padding(.top, 16)
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

    private var tagInfoPopover: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How tags work")
                .font(themeManager.effectiveTheme.interFont(size: 14, weight: .semibold))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)

            VStack(alignment: .leading, spacing: 8) {
                Text("**Primary** main muscle (e.g. chest). Weighted more in the tag breakdown.")
                    .font(themeManager.effectiveTheme.interFont(size: 13))
                    .foregroundStyle(themeManager.effectiveTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Text("**Secondary** supporting (e.g. triceps). Counted less.")
                    .font(themeManager.effectiveTheme.interFont(size: 13))
                    .foregroundStyle(themeManager.effectiveTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Text("History shows your training split by tag.")
                    .font(themeManager.effectiveTheme.interFont(size: 13))
                    .foregroundStyle(themeManager.effectiveTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .presentationCompactAdaptation(.popover)
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
