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
            filter: #Predicate<ExerciseSet> { $0.exercise.persistentModelID == id },
            sort: [SortDescriptor(\.timestamp, order: .reverse)]
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            // Quick Add section at top (fixed position)
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Add")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
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
            }
            .padding()
            .background(.regularMaterial)
            
            // History list below (scrollable)
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
        }
        .navigationTitle(exercise.name)
        .toolbar { 
            if !sets.isEmpty {
                ToolbarItem(placement: .secondaryAction) {
                    EditButton()
                }
            }
        }
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

    private func delete(at offsets: IndexSet) {
        offsets.map { sets[$0] }.forEach(context.delete)
        try? context.save()
    }

    private func formatWeight(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
}