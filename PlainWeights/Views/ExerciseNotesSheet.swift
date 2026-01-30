//
//  ExerciseNotesSheet.swift
//  PlainWeights
//
//  Sheet for editing exercise notes
//

import SwiftUI

struct ExerciseNotesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    let exercise: Exercise
    @Binding var noteText: String
    @FocusState private var isFocused: Bool
    let onSave: () -> Void

    private let maxLines = 10

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            HStack {
                Text("Exercise Notes")
                    .font(themeManager.currentTheme.title3Font)
                    .foregroundStyle(themeManager.currentTheme.primaryText)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(themeManager.currentTheme.mutedForeground)
                }
            }

            // Description
            Text("Add notes about form, target muscles, or any reminders for this exercise.")
                .font(themeManager.currentTheme.captionFont)
                .foregroundStyle(themeManager.currentTheme.mutedForeground)

            // Text editor
            TextEditor(text: $noteText)
                .font(themeManager.currentTheme.bodyFont)
                .scrollContentBackground(.hidden)
                .frame(height: 220)
                .padding(16)
                .background(themeManager.currentTheme.muted)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isFocused ? themeManager.currentTheme.mutedForeground : Color.clear, lineWidth: 2)
                )
                .focused($isFocused)
                .onChange(of: noteText) { oldValue, newValue in
                    let lines = newValue.components(separatedBy: .newlines)
                    if lines.count > maxLines {
                        noteText = oldValue
                    }
                }

            Spacer()

            // Save button
            Button {
                onSave()
                dismiss()
            } label: {
                Text("Save")
                    .font(themeManager.currentTheme.interFont(size: 17, weight: .semibold))
                    .foregroundStyle(themeManager.currentTheme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(themeManager.currentTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(24)
        .background(themeManager.currentTheme.backgroundColor)
        .onAppear {
            isFocused = true
        }
    }
}
