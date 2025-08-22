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

    @State private var weightText = ""
    @State private var repsText = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case weight, reps
    }

    init(exercise: Exercise) {
        self.exercise = exercise
        let id = exercise.persistentModelID
        _sets = Query(
            filter: #Predicate<ExerciseSet> { $0.exercise?.persistentModelID == id },
            sort: [SortDescriptor(\.timestamp, order: .reverse)]
        )
    }

    var body: some View {
        List {
            // Add Set section with custom styling
            Section("Add set") {
                HStack(spacing: 12) {
                    TextField("Weight", text: $weightText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .weight)
                        .frame(maxWidth: .infinity)
                    
                    TextField("Reps", text: $repsText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .reps)
                        .frame(maxWidth: .infinity)
                    
                    Button(action: addSet) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.tint)
                    }
                    .disabled(weightText.isEmpty || repsText.isEmpty)
                }
                .listRowBackground(Color(.systemGroupedBackground))
                .listRowSeparator(.hidden)
            }
            
            Section("History") {
                if sets.isEmpty {
                    Text("No sets yet").foregroundStyle(.secondary)
                } else {
                    ForEach(Array(sets.enumerated()), id: \.element) { index, set in
                        HStack {
                            Text("\(formatWeight(set.weight)) kg × \(set.reps)")
                                .monospacedDigit()
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Text(set.timestamp.formatted(
                                    Date.FormatStyle()
                                        .day().month(.abbreviated).year(.twoDigits)
                                        .hour().minute()
                                        .locale(Locale(identifier: "en_GB_POSIX")) // prevents the "at"
                                ))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                
                                // Add repeat button only for first item (most recent)
                                if index == 0 {
                                    Button {
                                        repeatSet(set)
                                    } label: {
                                        Image(systemName: "arrow.clockwise.circle.fill")
                                            .font(.title3)
                                            .foregroundStyle(.tint)
                                    }
                                }
                            }
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle(exercise.name)
    }

    private func addSet() {
        guard let weight = Double(weightText),
              let reps = Int(repsText),
              weight > 0,
              reps > 0 else { return }
        
        let set = ExerciseSet(weight: weight, reps: reps, exercise: exercise)
        context.insert(set)
        try? context.save()
        
        // Clear fields after adding
        weightText = ""
        repsText = ""
        focusedField = nil
    }
    
    private func repeatSet(_ set: ExerciseSet) {
        let newSet = ExerciseSet(
            weight: set.weight,
            reps: set.reps,
            exercise: exercise
        )
        context.insert(newSet)
        try? context.save()
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { sets[$0] }.forEach(context.delete)
        try? context.save()
    }

    private func formatWeight(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
}
