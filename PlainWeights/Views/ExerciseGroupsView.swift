//
//  ExerciseGroupsView.swift
//  PlainWeights
//
//  Lists all saved ExerciseGroups. Each group is rendered as a GroupCard —
//  tap a card's header to expand it accordion-style and reveal its
//  exercises. Tapping an exercise pushes the existing ExerciseDetailView,
//  so all set logging / PB tracking continues to flow against the one
//  underlying Exercise regardless of which group the user came from.
//
//  Group lifecycle (create / edit-membership) flows through a single
//  `fullScreenCover`. For `.creating`, the cover hosts a NavigationStack
//  whose root is a name-entry step that pushes onto the exercise
//  selection step. For `.editing`, the cover goes straight to selection.
//  This keeps the create flow inside one modal — no flash of the Groups
//  screen between dismissing a name sheet and presenting the cover.
//

import SwiftUI
import SwiftData

/// Drives the group-selection cover. Identifiable so it can be the
/// `item:` argument of `.fullScreenCover(item:)`.
enum GroupSelectionContext: Identifiable {
    /// User tapped "Create new group" — the name is entered inside the
    /// cover (first step in the internal NavigationStack).
    case creating
    /// User tapped "Edit exercises" on an existing group — the group's
    /// current members are pre-ticked.
    case editing(group: ExerciseGroup)

    var id: String {
        switch self {
        case .creating: return "creating"
        case .editing(let group): return "editing-\(group.id.uuidString)"
        }
    }
}

/// Result of the cover's selection flow, handed to the parent's commit.
private enum GroupCommit {
    case create(name: String, exercises: [Exercise])
    case update(ExerciseGroup, exercises: [Exercise])
}

/// Marker pushed onto the cover's internal NavigationStack when the user
/// taps Next on the name-entry step.
private enum SelectionStep: Hashable {
    case proceed
}

struct ExerciseGroupsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager

    /// Most recently created groups first.
    @Query(sort: \ExerciseGroup.createdDate, order: .reverse)
    private var groups: [ExerciseGroup]

    @Binding var navigationPath: NavigationPath

    /// Which group cards are currently expanded. UUID-keyed so the state
    /// survives reorderings of `groups`.
    @State private var expandedGroupIDs: Set<UUID> = []

    /// Non-nil while the selection cover is presented. Drives both the
    /// create flow and the edit-existing flow.
    @State private var draftContext: GroupSelectionContext?

    var body: some View {
        Group {
            if groups.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(groups) { group in
                            GroupCard(
                                group: group,
                                isExpanded: expandedGroupIDs.contains(group.id),
                                onToggle: { toggleExpansion(for: group) },
                                onEditExercises: { draftContext = .editing(group: group) },
                                navigationPath: $navigationPath
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .scrollIndicators(.hidden)
                .background(AnimatedGradientBackground())
            }
        }
        .navigationTitle("Groups")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .safeAreaInset(edge: .bottom, alignment: .trailing, spacing: 0) {
            Button(action: { draftContext = .creating }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundStyle(themeManager.effectiveTheme.background)
            }
            .frame(width: 55, height: 55)
            .background(themeManager.effectiveTheme.primary)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            .accessibilityLabel("Create new group")
            .padding(.trailing, 20)
            .padding(.bottom, 3)
        }
        .fullScreenCover(item: $draftContext) { context in
            GroupSelectionCover(
                context: context,
                onCommit: handleCommit,
                onCancel: { draftContext = nil }
            )
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
    }

    // MARK: - Flow handlers

    private func handleCommit(_ commit: GroupCommit) {
        switch commit {
        case .create(let name, let exercises):
            let group = ExerciseGroup(name: name, exercises: exercises)
            modelContext.insert(group)
        case .update(let group, let exercises):
            group.exercises = exercises
        }
        try? modelContext.save()
        draftContext = nil
    }

    private func toggleExpansion(for group: ExerciseGroup) {
        withAnimation(.easeInOut(duration: 0.22)) {
            if expandedGroupIDs.contains(group.id) {
                expandedGroupIDs.remove(group.id)
            } else {
                expandedGroupIDs.insert(group.id)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("No groups yet")
                .font(themeManager.effectiveTheme.title2Font)
                .foregroundStyle(themeManager.effectiveTheme.primaryText)
            Text("Tap the + button below to create your first workout group.")
                .font(themeManager.effectiveTheme.subheadlineFont)
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }
}

// MARK: - Selection cover

/// Single fullScreenCover that handles both the create flow (name → select)
/// and the edit flow (select directly).
private struct GroupSelectionCover: View {
    let context: GroupSelectionContext
    let onCommit: (GroupCommit) -> Void
    let onCancel: () -> Void

    @State private var path = NavigationPath()
    @State private var draftName: String = ""

    var body: some View {
        NavigationStack(path: $path) {
            rootStep
                .navigationDestination(for: SelectionStep.self) { _ in
                    SelectionScreen(
                        contextLabel: draftName,
                        initialSelection: [],
                        showsCancel: false,  // pushed — Back button handles dismiss
                        onSubmit: { exercises in
                            onCommit(.create(name: draftName, exercises: exercises))
                        },
                        onCancel: onCancel
                    )
                }
        }
    }

    @ViewBuilder
    private var rootStep: some View {
        switch context {
        case .creating:
            NameEntryStep(
                draftName: $draftName,
                onNext: { path.append(SelectionStep.proceed) },
                onCancel: onCancel
            )
        case .editing(let group):
            SelectionScreen(
                contextLabel: group.name,
                initialSelection: Set((group.exercises ?? []).map(\.persistentModelID)),
                showsCancel: true,  // root — no Back button, Cancel is the only dismiss
                onSubmit: { exercises in
                    onCommit(.update(group, exercises: exercises))
                },
                onCancel: onCancel
            )
        }
    }
}

// MARK: - Name entry step (root of the create flow)

private struct NameEntryStep: View {
    @Environment(ThemeManager.self) private var themeManager

    @Binding var draftName: String
    let onNext: () -> Void
    let onCancel: () -> Void

    @FocusState private var nameFieldFocused: Bool

    private var trimmed: String {
        draftName.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var canProceed: Bool { !trimmed.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(themeManager.effectiveTheme.interFont(size: 11, weight: .semibold))
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    .textCase(.uppercase)
                    .tracking(0.8)

                TextField(
                    "",
                    text: $draftName,
                    prompt: Text("e.g. Leg Day")
                        .foregroundStyle(themeManager.effectiveTheme.primary.opacity(0.18))
                )
                .focused($nameFieldFocused)
                .font(themeManager.effectiveTheme.dataFont(size: 20))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)
                .submitLabel(.next)
                .onSubmit { if canProceed { onNext() } }
                .onChange(of: draftName) { _, newValue in
                    if newValue.count > 50 { draftName = String(newValue.prefix(50)) }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(themeManager.effectiveTheme.cardBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()
        }
        .padding(24)
        .background(themeManager.effectiveTheme.surfaceColor)
        .navigationTitle("New Group")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { onCancel() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Next") { onNext() }
                    .disabled(!canProceed)
                    .fontWeight(.semibold)
            }
        }
        .task {
            // Brief delay so the cover slide-up finishes before the keyboard rises.
            try? await Task.sleep(for: .milliseconds(200))
            nameFieldFocused = true
        }
    }
}

// MARK: - Selection screen (the main list in selection mode)

private struct SelectionScreen: View {
    let contextLabel: String
    let initialSelection: Set<PersistentIdentifier>
    let showsCancel: Bool
    let onSubmit: ([Exercise]) -> Void
    let onCancel: () -> Void

    @State private var searchText = ""
    @State private var searchScope: ExerciseSearchScope = .name
    @State private var dummyShowingAdd = false  // FAB hidden in selection mode
    @State private var dummyPath = NavigationPath()  // unused — selection mode doesn't navigate

    var body: some View {
        FilteredExerciseListView(
            searchText: searchText,
            searchScope: searchScope,
            showingAddExercise: $dummyShowingAdd,
            navigationPath: $dummyPath,
            mode: .selectingForGroup(
                contextLabel: contextLabel,
                initialSelection: initialSelection,
                showsCancel: showsCancel,
                onSubmit: onSubmit,
                onCancel: onCancel
            )
        )
        .searchable(text: $searchText, prompt: "Search exercises")
        .searchScopes($searchScope, activation: .onTextEntry) {
            Text("Name").tag(ExerciseSearchScope.name)
            Text("Tags").tag(ExerciseSearchScope.tags)
        }
    }
}
