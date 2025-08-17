//
//  ExerciseDetailView.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 16/08/2025.
//

import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var context
    let exercise: Exercise
    @Query private var sets: [ExerciseSet]

    @State private var showingAdd = false

    init(exercise: Exercise) {
        self.exercise = exercise
        let id = exercise.persistentModelID
        _sets = Query(
            filter: #Predicate<ExerciseSet> { $0.exercise.persistentModelID == id },
            sort: [SortDescriptor(\.timestamp, order: .reverse)]
        )
    }

    var body: some View {
        List {
            Section("History") {
                if sets.isEmpty {
                    Text("No sets yet").foregroundStyle(.secondary)
                } else {
                    ForEach(sets) { set in
                        HStack {
                            Text("\(formatWeight(set.weight)) kg × \(set.reps)")
                                .monospacedDigit()
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(set.timestamp, format: .dateTime.day().month().year())
                                Text(set.timestamp, format: .dateTime.hour().minute())
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
        }
        .navigationTitle(exercise.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAdd = true
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                }
            }
            if !sets.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddSetForm(exercise: exercise) { newSet in
                context.insert(newSet)
                try? context.save()
            }
            .presentationDetents([.medium])
        }
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { sets[$0] }.forEach(context.delete)
        try? context.save()
    }

    private func formatWeight(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
}

struct AddSetForm: View {
    let exercise: Exercise
    var onSave: (ExerciseSet) -> Void

    @State private var weight: Double? = nil
    @State private var reps: Int? = nil
    @State private var showValidation = false
    @FocusState private var focus: Field?
    enum Field { case weight, reps }

    var body: some View {
        NavigationStack {
            Form {
                Section("Add set") {
                    LabeledContent("Weight (kg)") {
                        TextField("0", value: $weight, format: .number.precision(.fractionLength(0...1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .monospacedDigit()
                            .focused($focus, equals: .weight)
                            .submitLabel(.next)
                    }
                    LabeledContent("Reps") {
                        TextField("0", value: $reps, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .monospacedDigit()
                            .focused($focus, equals: .reps)
                            .submitLabel(.done)
                    }
                    if showValidation {
                        Text("Enter a positive weight and reps.")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Add set")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.bold()
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear { focus = .weight }
            .onSubmit { focus == .weight ? (focus = .reps) : save() }
        }
    }

    @Environment(\.dismiss) private var dismiss
    private func save() {
        guard let w = weight, let r = reps, w > 0, r > 0 else { showValidation = true; return }
        onSave(ExerciseSet(weight: w, reps: r, exercise: exercise))
        dismiss()
    }
}