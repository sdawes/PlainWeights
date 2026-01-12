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

    // Callback to notify parent when exercise is created
    let onExerciseCreated: ((Exercise) -> Void)?

    init(onExerciseCreated: ((Exercise) -> Void)? = nil) {
        self.onExerciseCreated = onExerciseCreated
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
                        TextField("Add tags (space to add)", text: $tagInput)
                            .font(.jetBrainsMono(.body))
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
                    }
                    .listRowBackground(
                        themeManager.currentTheme == .dark ? Color.clear : Color(.systemBackground)
                    )
                }
            }
            .scrollContentBackground(.hidden)
            .background(AnimatedGradientBackground())
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Add Exercise")
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

                        let newExercise = Exercise(name: name, tags: finalTags)
                        modelContext.insert(newExercise)
                        try? modelContext.save()
                        dismiss()

                        // Call callback with newly created exercise
                        onExerciseCreated?(newExercise)
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}