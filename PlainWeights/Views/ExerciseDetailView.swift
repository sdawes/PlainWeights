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
    @State private var name: String
    @FocusState private var nameFocused: Bool
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
        _name = State(initialValue: exercise.name)
    }
    
    // MARK: - Volume Metrics Computation
    
    private var todaysSets: [ExerciseSet] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sets.filter { calendar.startOfDay(for: $0.timestamp) == today }
    }
    
    private var todayVolume: Double {
        todaysSets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
    
    private var lastCompletedDayInfo: (date: Date, volume: Double)? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Group sets by day
        let setsByDay = Dictionary(grouping: sets) { set in
            calendar.startOfDay(for: set.timestamp)
        }
        
        // Find the most recent day before today with sets
        let pastDays = setsByDay.keys.filter { $0 < today }.sorted(by: >)
        
        guard let lastDay = pastDays.first,
              let lastDaySets = setsByDay[lastDay] else {
            return nil
        }
        
        let volume = lastDaySets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
        return (lastDay, volume)
    }
    
    private var progressRatio: Double {
        guard let lastInfo = lastCompletedDayInfo, lastInfo.volume > 0 else { return 0 }
        return min(todayVolume / lastInfo.volume, 1.2)
    }
    
    private var deltaText: String {
        guard let lastInfo = lastCompletedDayInfo else {
            return "Baseline day"
        }
        
        let delta = todayVolume - lastInfo.volume
        let sign = delta >= 0 ? "+" : ""
        let dateFormatted = formatDeltaDate(lastInfo.date)
        
        return "\(sign)\(formatVolume(delta)) kg vs \(dateFormatted)"
    }
    
    private var showProgressBar: Bool {
        lastCompletedDayInfo != nil && lastCompletedDayInfo!.volume > 0
    }
    
    // MARK: - Formatting Helpers
    
    private func formatVolume(_ volume: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: volume)) ?? "0"
    }
    
    private func formatDeltaDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d MMM"  // e.g., "Thu 14 Aug"
        return formatter.string(from: date)
    }

    var body: some View {
        List {
            // Title field like Apple Notes
            Section {
                TextField("Title", text: $name)
                    .font(.largeTitle).bold()
                    .textFieldStyle(.plain)
                    .focused($nameFocused)
                    .submitLabel(.done)
                    .onSubmit { endEditing() }
            }
            
            // Volume tracking header
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    // Today's volume
                    Text("Today \(formatVolume(todayVolume)) kg")
                        .font(.title2)
                        .bold()
                        .monospacedDigit()
                    
                    // Delta chip
                    Text(deltaText)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(Capsule())
                    
                    // Progress bar (if applicable)
                    if showProgressBar {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.2))
                                Rectangle()
                                    .fill(Color.accentColor)
                                    .frame(width: geometry.size.width * progressRatio)
                                    .animation(.easeInOut(duration: 0.3), value: progressRatio)
                            }
                        }
                        .frame(height: 4)
                        .clipShape(Capsule())
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Add Set section with custom styling
            Section("Add set") {
                HStack(spacing: 12) {
                    TextField("Weight", text: $weightText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($focusedField, equals: .weight)
                        .frame(maxWidth: .infinity)
                    
                    TextField("Reps", text: $repsText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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
                    ForEach(sets.indices, id: \.self) { index in
                        let set = sets[index]
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if nameFocused { Button("Done") { endEditing() } }
            }

            ToolbarItem(placement: .keyboard) {
                HStack { Spacer(); Button("Done") { endEditing() } }
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
        // lastUpdated is now automatically updated in ExerciseSet.init
        
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
        // lastUpdated is now automatically updated in ExerciseSet.init
        
        try? context.save()
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { sets[$0] }.forEach(context.delete)
        try? context.save()
    }

    private func formatWeight(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
    
    private func endEditing() {
        nameFocused = false
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != exercise.name else { return }
        exercise.name = trimmed
        
        // Update exercise lastUpdated timestamp when name changes
        exercise.bumpUpdated()
        
        try? context.save()
    }
}
