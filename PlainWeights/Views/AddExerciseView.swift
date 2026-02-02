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
    @FocusState private var nameFieldFocused: Bool
    @FocusState private var tagFieldFocused: Bool

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
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header (like AddSetView)
            HStack {
                Text(screenTitle)
                    .font(themeManager.currentTheme.title3Font)
                    .foregroundStyle(themeManager.currentTheme.primaryText)
                    .lineLimit(1)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(themeManager.currentTheme.mutedForeground)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 16)

            // Header divider
            Rectangle()
                .fill(themeManager.currentTheme.borderColor)
                .frame(height: 1)
                .padding(.horizontal, -24)

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    exerciseNameSection
                    tagsSection
                }
                .padding(.top, 24)
            }

            Spacer()

            // Bottom CTA button
            addButton
        }
        .padding(24)
        .background(themeManager.currentTheme.background)
        .onAppear {
            // Auto-focus name field when view appears
            nameFieldFocused = true
        }
    }

    // MARK: - Exercise Name Section

    private var exerciseNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Exercise Name")
                .font(themeManager.currentTheme.interFont(size: 15, weight: .medium))
                .foregroundStyle(themeManager.currentTheme.mutedForeground)

            TextField("e.g. Romanian Deadlift", text: $name)
                .font(themeManager.currentTheme.dataFont(size: 20))
                .foregroundStyle(themeManager.currentTheme.primaryText)
                .padding(16)
                .frame(height: 56)
                .background(themeManager.currentTheme.cardBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            nameFieldFocused ? themeManager.currentTheme.primaryText : themeManager.currentTheme.borderColor,
                            lineWidth: nameFieldFocused ? 2 : 1
                        )
                )
                .focused($nameFieldFocused)
                .onSubmit {
                    tagFieldFocused = true
                }
        }
    }

    // MARK: - Tags Section

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags (optional)")
                .font(themeManager.currentTheme.interFont(size: 15, weight: .medium))
                .foregroundStyle(themeManager.currentTheme.mutedForeground)

            HStack(spacing: 8) {
                TextField("e.g. chest, push, strength", text: $tagInput)
                    .font(themeManager.currentTheme.dataFont(size: 20))
                    .foregroundStyle(themeManager.currentTheme.primaryText)
                    .padding(16)
                    .frame(height: 56)
                    .background(themeManager.currentTheme.cardBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                tagFieldFocused ? themeManager.currentTheme.primaryText : themeManager.currentTheme.borderColor,
                                lineWidth: tagFieldFocused ? 2 : 1
                            )
                    )
                    .focused($tagFieldFocused)
                    .onSubmit {
                        addTag()
                        // Keep focus for continuous entry
                        tagFieldFocused = true
                    }

                Button(action: addTag) {
                    let isDisabled = tagInput.trimmingCharacters(in: .whitespaces).isEmpty
                    Text("Add")
                        .font(themeManager.currentTheme.headlineFont)
                        .foregroundStyle(themeManager.currentTheme.background)
                        .padding(.horizontal, 16)
                        .frame(height: 56)
                        .background(isDisabled ? themeManager.currentTheme.primary.opacity(0.4) : themeManager.currentTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(tagInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // Tag pills
            if !tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        TagPillView(tag: tag) {
                            withAnimation { tags.removeAll { $0 == tag } }
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Add Button

    private var addButton: some View {
        Button(action: saveExercise) {
            Text(isEditMode ? "Save Changes" : "Add Exercise")
                .font(themeManager.currentTheme.headlineFont)
                .foregroundStyle(themeManager.currentTheme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(name.isEmpty ? themeManager.currentTheme.primary.opacity(0.4) : themeManager.currentTheme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(name.isEmpty)
    }

    // MARK: - Actions

    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespaces).lowercased()
        if !trimmed.isEmpty && !tags.contains(trimmed) && tags.count < 10 {
            withAnimation {
                tags.append(trimmed)
            }
        }
        tagInput = ""
    }

    private func saveExercise() {
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
}
