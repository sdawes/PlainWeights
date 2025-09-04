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
    
    private var progressRatioUnclamped: Double {
        guard let lastInfo = lastCompletedDayInfo, lastInfo.volume > 0 else { return 0 }
        return todayVolume / lastInfo.volume
    }

    private var progressBarRatio: Double {
        min(progressRatioUnclamped, 1.0) // bar caps at 100%
    }

    private var percentOfLast: Int {
        Int(round(progressRatioUnclamped * 100)) // can exceed 100
    }
    
    private var gainsPercent: Int {
        guard let lastInfo = lastCompletedDayInfo, lastInfo.volume > 0 else { return 0 }
        let gain = (todayVolume - lastInfo.volume) / lastInfo.volume * 100
        return Int(round(gain))
    }
    
    private var deltaText: String {
        guard let lastInfo = lastCompletedDayInfo else {
            return "Baseline day"
        }

        let delta = todayVolume - lastInfo.volume
        let sign = delta >= 0 ? "+" : ""
        let dateFormatted = formatDeltaDate(lastInfo.date)

        let percentPart: String
        if lastInfo.volume > 0 {
            let deltaPercent = Int(round((delta / lastInfo.volume) * 100))
            let pSign = deltaPercent >= 0 ? "+" : ""
            percentPart = " (\(pSign)\(deltaPercent)%)"
        } else {
            percentPart = ""
        }

        return "\(sign)\(formatVolume(delta)) kg\(percentPart) vs \(dateFormatted)"
    }
    
    private var showProgressBar: Bool {
        lastCompletedDayInfo != nil && lastCompletedDayInfo!.volume > 0
    }
    
    private var barFillColor: Color {
        percentOfLast >= 100 ? .green : .accentColor
    }

    private var gainsColor: Color {
        if gainsPercent > 0 { return .green }
        if gainsPercent < 0 { return .red }
        return .secondary
    }
    
    // MARK: - Data Grouping
    
    private var groupedByDay: [(Date, [ExerciseSet])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sets) { set in
            calendar.startOfDay(for: set.timestamp)
        }
        return grouped.sorted { $0.key > $1.key }  // Most recent first
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
    
    private func formatDayHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"  // e.g., "Thursday, 14 August 2025"
        return formatter.string(from: date)
    }

    var body: some View {
        List {
            // Title row (no Section wrapper)
            TextField("Title", text: $name)
                .font(.largeTitle.bold())
                .textFieldStyle(.plain)
                .focused($nameFocused)
                .submitLabel(.done)
                .onSubmit { endEditing() }
                .listRowSeparator(.hidden)
                .padding(.vertical, 8)
            
            // Volume tracking metrics row
            VStack(alignment: .leading, spacing: 6) {
                // Today's volume
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("Today: \(formatVolume(todayVolume)) kg")
                        .font(.title2)
                        .bold()
                        .monospacedDigit()

                    if showProgressBar {
                        // Achievement: percent of last (matches progress bar color)
                        Text("· \(percentOfLast)% of last")
                            .font(.headline)
                            .monospacedDigit()
                            .foregroundStyle(barFillColor)
                            .accessibilityLabel("You have reached \(percentOfLast) percent of your last daily total")
                    }
                }
                
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
                                .fill(barFillColor)
                                .frame(width: geometry.size.width * progressBarRatio)
                                .animation(.easeInOut(duration: 0.3), value: progressBarRatio)
                        }
                    }
                    .frame(height: 4)
                    .clipShape(Capsule())
                }
            }
            .listRowSeparator(.hidden)
            .padding(.vertical, 10)
            
            // Quick-add row
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
            .listRowSeparator(.hidden)
            .padding(.vertical, 8)
            
            // History label row
            Text("HISTORIC SETS")
                .font(.footnote)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
                .listRowSeparator(.hidden)
                .padding(.vertical, 4)
            
            // Grouped history rows
            if sets.isEmpty {
                Text("No sets yet")
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(groupedByDay, id: \.0) { day, daySets in
                    Section {
                        let firstID = daySets.first?.persistentModelID
                        let lastID = daySets.last?.persistentModelID
                        
                        ForEach(daySets, id: \.persistentModelID) { set in
                            let isFirst = (set.persistentModelID == firstID)
                            let isLast = (set.persistentModelID == lastID)
                            
                            HStack {
                                Text("\(formatWeight(set.weight)) kg × \(set.reps)")
                                    .monospacedDigit()
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Text(set.timestamp.formatted(
                                        Date.FormatStyle()
                                            .hour().minute()
                                            .locale(Locale(identifier: "en_GB_POSIX"))
                                    ))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    
                                    // Add repeat button only for first item (most recent overall)
                                    if set.persistentModelID == sets.first?.persistentModelID {
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
                            .listRowSeparator(isFirst ? .hidden : .visible, edges: .top)
                            .listRowSeparator(isLast ? .hidden : .visible, edges: .bottom)
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    deleteSet(set)
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Text(day.formatted(Date.FormatStyle().weekday(.abbreviated).day().month(.abbreviated)))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            let dayVolume = daySets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
                            Text("\(formatVolume(dayVolume)) kg")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
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

    private func deleteSet(_ set: ExerciseSet) {
        withAnimation {
            context.delete(set)
            try? context.save()
        }
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
