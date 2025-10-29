//
//  ExerciseNotesSheet.swift
//  PlainWeights
//
//  Sheet for editing exercise notes
//

import SwiftUI

struct ExerciseNotesSheet: View {
    @Environment(\.dismiss) private var dismiss
    let exercise: Exercise
    @Binding var noteText: String
    @FocusState private var isFocused: Bool
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Add notes about form, target muscles, or any reminders for this exercise.")
                    .font(.caption)
                    .foregroundStyle(.black)

                TextEditor(text: $noteText)
                    .font(.body)
                    .frame(minHeight: 150)
                    .padding(8)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .focused($isFocused)

                Spacer()
            }
            .padding()
            .background(Color.white)
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
        .presentationDetents([.medium, .large])
    }
}
