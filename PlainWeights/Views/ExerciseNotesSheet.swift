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
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Add notes about form, target muscles, or any reminders for this exercise.")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(themeManager.currentTheme.textColor)

                TextEditor(text: $noteText)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 220)
                    .padding(8)
                    .background(themeManager.currentTheme.cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(themeManager.currentTheme.textColor, lineWidth: 1)
                    )
                    .focused($isFocused)
                    .onChange(of: noteText) { oldValue, newValue in
                        let lines = newValue.components(separatedBy: .newlines)
                        if lines.count > maxLines {
                            noteText = oldValue
                        }
                    }

                Spacer()
            }
            .padding()
            .background(themeManager.currentTheme.backgroundColor)
            .navigationTitle("Exercise Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onSave()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isFocused = true
            }
        }
    }
}
