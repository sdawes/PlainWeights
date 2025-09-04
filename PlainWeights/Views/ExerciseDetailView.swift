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
    
    @State private var viewModel: ExerciseDetailViewModel?

    init(exercise: Exercise) {
        self.exercise = exercise
        let id = exercise.persistentModelID
        _sets = Query(
            filter: #Predicate<ExerciseSet> { $0.exercise?.persistentModelID == id },
            sort: [SortDescriptor(\.timestamp, order: .reverse)]
        )
    }

    var body: some View {
        Group {
            if let vm = viewModel {
                ExerciseDetailContent(viewModel: vm, sets: sets)
            } else {
                ProgressView()
                    .onAppear {
                        viewModel = ExerciseDetailViewModel(exercise: exercise, context: context)
                        viewModel?.updateComputedProperties(with: sets)
                    }
            }
        }
        .onChange(of: sets) { _, newSets in
            viewModel?.updateComputedProperties(with: newSets)
        }
    }
}

// MARK: - Content View

private struct ExerciseDetailContent: View {
    @Bindable var viewModel: ExerciseDetailViewModel
    let sets: [ExerciseSet]
    
    @FocusState private var nameFocused: Bool
    @FocusState private var focusedField: ExerciseDetailViewModel.Field?
    
    var body: some View {
        List {
            // Title row
            TextField("Title", text: $viewModel.name)
                .font(.largeTitle.bold())
                .textFieldStyle(.plain)
                .focused($nameFocused)
                .submitLabel(.done)
                .onSubmit { 
                    nameFocused = false
                    viewModel.endEditing() 
                }
                .listRowSeparator(.hidden)
                .padding(.vertical, 8)
            
            // Volume tracking metrics row
            if let progressState = viewModel.progressState {
                VolumeMetricsView(progressState: progressState)
            }
            
            // Quick-add row
            QuickAddView(viewModel: viewModel, focusedField: $focusedField)
            
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
                HistorySectionView(viewModel: viewModel, sets: sets)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if nameFocused { 
                    Button("Done") { 
                        nameFocused = false
                        viewModel.endEditing() 
                    } 
                }
            }

            ToolbarItem(placement: .keyboard) {
                HStack { 
                    Spacer()
                    Button("Done") { 
                        focusedField = nil 
                    } 
                }
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }
}

// MARK: - Volume Metrics View

private struct VolumeMetricsView: View {
    let progressState: ProgressTracker.ProgressState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Today's volume
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Today: \(Formatters.formatVolume(progressState.todayVolume)) kg")
                    .font(.title2)
                    .bold()
                    .monospacedDigit()

                if progressState.showProgressBar {
                    Text("· \(progressState.percentOfLast)% of last")
                        .font(.headline)
                        .monospacedDigit()
                        .foregroundStyle(progressState.barFillColor)
                        .accessibilityLabel("You have reached \(progressState.percentOfLast) percent of your last daily total")
                }
            }
            
            // Delta chip
            Text(progressState.deltaText)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.2))
                .clipShape(Capsule())
            
            // Progress bar (if applicable)
            if progressState.showProgressBar {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                        Rectangle()
                            .fill(progressState.barFillColor)
                            .frame(width: geometry.size.width * progressState.progressBarRatio)
                            .animation(.easeInOut(duration: 0.3), value: progressState.progressBarRatio)
                    }
                }
                .frame(height: 4)
                .clipShape(Capsule())
            }
        }
        .listRowSeparator(.hidden)
        .padding(.vertical, 10)
    }
}

// MARK: - Quick Add View

private struct QuickAddView: View {
    @Bindable var viewModel: ExerciseDetailViewModel
    @FocusState.Binding var focusedField: ExerciseDetailViewModel.Field?
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Weight", text: $viewModel.weightText)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .weight)
                .frame(maxWidth: .infinity)
            
            TextField("Reps", text: $viewModel.repsText)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .reps)
                .frame(maxWidth: .infinity)
            
            Button(action: viewModel.addSet) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.tint)
            }
            .disabled(!viewModel.canAddSet)
        }
        .listRowSeparator(.hidden)
        .padding(.vertical, 8)
    }
}

// MARK: - History Section View

private struct HistorySectionView: View {
    let viewModel: ExerciseDetailViewModel
    let sets: [ExerciseSet]
    
    var body: some View {
        ForEach(viewModel.dayGroups, id: \.date) { dayGroup in
            Section {
                ForEach(dayGroup.sets, id: \.persistentModelID) { set in
                    HStack {
                        Text("\(viewModel.formattedWeight(set.weight)) kg × \(set.reps)")
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
                            
                            // Add repeat button only for most recent set overall
                            if viewModel.isMostRecentSet(set, in: sets) {
                                Button {
                                    viewModel.repeatSet(set)
                                } label: {
                                    Image(systemName: "arrow.clockwise.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                    }
                    .listRowSeparator(dayGroup.isFirst(set) ? .hidden : .visible, edges: .top)
                    .listRowSeparator(dayGroup.isLast(set) ? .hidden : .visible, edges: .bottom)
                    .swipeActions {
                        Button("Delete", role: .destructive) {
                            viewModel.deleteSet(set)
                        }
                    }
                }
            } header: {
                HStack {
                    Text(viewModel.formattedDayHeader(for: dayGroup.date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("\(viewModel.formattedVolume(dayGroup.volume)) kg")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}