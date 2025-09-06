# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PlainWeights is a high-performance gym workout tracking app built with SwiftUI and SwiftData. The app focuses on recording exercises, sets, and reps with optimized data aggregation for real-time charts and statistics using Swift Charts.

## Core Requirements

### Technology Stack
- **SwiftUI**: Latest features and best practices only
- **SwiftData**: For persistent storage with performance-optimized queries
- **Swift Testing**: New testing framework with `@Test` attributes (NOT XCTest for unit tests)
- **Swift Charts**: For data visualization
- **Minimum iOS Target**: iOS 17+ (to use latest SwiftData and SwiftUI features)

### Performance Priorities - CRITICAL
**PERFORMANCE IS THE #1 PRIORITY - Every millisecond matters**
- All data operations MUST be database-level (NEVER in-memory filtering)
- Implement aggressive caching with smart invalidation
- Use lazy loading and pagination for ALL datasets
- Minimize view re-renders using computed properties and `@Observable` macro
- Background processing mandatory for any operation > 16ms
- Batch operations required for all multi-item updates
- Profile with Instruments before and after EVERY feature

### SwiftData Best Practices - CRITICAL

**IMPORTANT: SwiftData is designed to be used directly in views. DO NOT overcomplicate with unnecessary abstraction layers.**

#### SwiftData Architecture Principles (MUST FOLLOW)
- **ALWAYS use SwiftData patterns directly** - `@Environment(\.modelContext)` and `@Query` in views
- **NEVER add unnecessary ViewModel layers** - SwiftData provides reactive updates automatically
- **NEVER try to "improve" SwiftData with MVVM** - It breaks the framework's elegant design
- **DO use Services for business logic** - But call them directly from views, not through ViewModels

#### Correct SwiftData Pattern
```swift
// ✅ CORRECT - Direct SwiftData usage
struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var context
    @Query private var sets: [ExerciseSet]
    @State private var weightText = ""
    
    private func addSet() {
        let set = ExerciseSet(weight: weight, reps: reps, exercise: exercise)
        context.insert(set)
        try? context.save()
    }
}

// ❌ WRONG - Unnecessary ViewModel layer
@Observable class ExerciseDetailViewModel {
    private let context: ModelContext  // This breaks SwiftData's design
    // ViewModels add complexity without benefit
}
```

#### When to Use Services vs Direct Code
- **Use Services for:** Complex calculations, data aggregation, formatting utilities
- **Use Direct Code for:** Simple CRUD operations, form state, UI state
- **Never use ViewModels for:** Wrapping ModelContext or @Query results

### Data Model Architecture

#### Core Entities
- **Exercise**: Name, category (free text String - user can type anything), created date, lastUpdated date
  - Includes `bumpUpdated()` helper method for manual timestamp updates
  - lastUpdated automatically updated when sets are added
- **WorkoutSession**: Date, exercises performed
- **ExerciseSet**: Reps, weight, optional exercise reference, timestamp
  - Automatically updates parent Exercise.lastUpdated when created
  - Exercise relationship is optional to handle SwiftData cascade deletion
- **Metrics**: Cached/computed statistics for performance

**IMPORTANT**: 
- Exercise category is a free-text String field. Users can type any category name they want (e.g., "Biceps", "Triceps", "Cardio", "Custom Category"). DO NOT change this to an enum or dropdown - keep it as open text input.
- ExerciseSet.exercise is OPTIONAL to handle cascade deletion properly (SwiftData requirement)
- Exercise.lastUpdated is automatically updated in ExerciseSet.init() for reliable ordering
- Use optional chaining (?.) when querying ExerciseSet relationships in predicates

#### Performance Optimizations
- Use SwiftData's `@Model` with indexed properties for frequent queries
- Implement `@Query` with predicates and sort descriptors
- Cache aggregated data (weekly/monthly totals, PRs, trends)
- Use `ModelContext` batch operations for bulk updates
- Implement background contexts for heavy computations

### Development Standards

When implementing features, ALWAYS:
1. Check latest Apple documentation for newest APIs
2. Use `@Observable` macro instead of `ObservableObject`
3. Implement `@Query` with proper predicates for efficient data fetching
4. Use Swift Concurrency (async/await) for all asynchronous operations
5. Leverage `TaskGroup` for parallel data processing
6. Implement proper error handling with typed throws (Swift 6)

### Testing Requirements
- Tests will be specified by the user - do not write tests proactively
- Use Swift Testing framework (`import Testing`)
- Focus on performance testing for data operations
- Mock SwiftData contexts for unit tests

## Build and Development Commands

### Building the Project
```bash
# Build for Debug configuration (iOS Simulator - RECOMMENDED FOR TESTING)
xcodebuild -scheme PlainWeights -configuration Debug build -destination "platform=iOS Simulator,name=iPhone 16"

# Build for Debug configuration (any platform - may default to macOS and fail)
xcodebuild -scheme PlainWeights -configuration Debug build

# Build for Release configuration  
xcodebuild -scheme PlainWeights -configuration Release build -destination "platform=iOS Simulator,name=iPhone 16"

# Clean build folder
xcodebuild -scheme PlainWeights clean
```

**IMPORTANT**: Always use the iOS Simulator destination when testing builds, as this is an iOS app and building without a destination may default to macOS and fail.

### Running Tests
```bash
# Run all tests
xcodebuild -scheme PlainWeights test

# Run unit tests only
xcodebuild -scheme PlainWeights -only-testing:PlainWeightsTests test

# Run UI tests only
xcodebuild -scheme PlainWeights -only-testing:PlainWeightsUITests test

# Run a specific test
xcodebuild -scheme PlainWeights -only-testing:PlainWeightsTests/PlainWeightsTests/example test
```

### Running the App
```bash
# Run in simulator
xcodebuild -scheme PlainWeights -destination 'platform=iOS Simulator,name=iPhone 16' run

# List available simulators
xcrun simctl list devices
```

## Architecture Guidelines

### View Layer (SwiftData-First Approach)
- **USE SWIFTDATA DIRECTLY IN VIEWS** - No unnecessary ViewModels
- Use `@Environment(\.modelContext)` for data operations
- Use `@Query` with predicates for reactive data fetching
- Use `NavigationStack` with value-based navigation
- Implement `.task` modifier for async data loading
- Use `@State` for UI state, not data state (SwiftData handles that)
- Leverage `ViewThatFits` for responsive layouts
- Use `.sensoryFeedback` for haptic feedback

### Data Layer (Pure SwiftData)
- **Direct ModelContext usage** - Don't wrap in ViewModels
- SwiftData models with proper relationships
- `@Query` provides automatic reactivity - trust it
- Implement custom `FetchDescriptor` for complex queries
- Use `@Query` animations for smooth updates
- Background `ModelContext` for intensive operations
- Implement proper migration schemas
- Let SwiftData handle synchronization - don't fight it

### Charts and Analytics
- Pre-calculate and cache chart data points
- Use `ChartProxy` for interactive features
- Implement data windowing for large datasets
- Background queue for statistical calculations
- Consider using `TimelineView` for real-time updates

### Performance Patterns (SwiftData-First)
```swift
// ✅ CORRECT: Direct SwiftData in Views
struct ExerciseListView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Exercise> { $0.category == "Chest" })
    private var chestExercises: [Exercise]
    
    // Simple operations directly in view
    private func deleteExercise(_ exercise: Exercise) {
        context.delete(exercise)
        try? context.save()
    }
}

// ✅ CORRECT: Services for complex logic only
enum VolumeAnalytics {
    static func calculateVolume(for sets: [ExerciseSet]) -> Double {
        // Complex calculation logic
    }
}

// ❌ WRONG: Wrapping SwiftData in ViewModels
@Observable class ExerciseViewModel {
    private let context: ModelContext  // Don't do this!
    @Query var exercises: [Exercise]   // This won't work properly
}

// Batch operations (still valid)
modelContext.transaction {
    // Multiple operations
}

// Background processing (still valid)
Task.detached(priority: .background) {
    // Heavy calculations
}
```

## Clean Architecture Structure (UPDATED SEPTEMBER 2025)

**IMPORTANT: Use Services for business logic, but NEVER wrap SwiftData in ViewModels. Views should use @Environment(\.modelContext) directly.**

### 📁 **Current Folder Structure:**
```
PlainWeights/
├── Models/ (SwiftData models - keep simple)
│   ├── Exercise.swift ✅ Clean data model
│   └── ExerciseSet.swift ✅ Clean data model
├── Views/ (SwiftUI views - UI ONLY)
│   ├── ExerciseDetailView.swift (refactored - clean UI only)
│   ├── ExerciseListView.swift ✅ Clean
│   └── AddExerciseView.swift ✅ Clean
├── ViewModels/ (State management & coordination)
│   └── ExerciseDetailViewModel.swift ✅ Coordinates services
├── Services/ (Business logic & calculations)
│   ├── VolumeAnalytics.swift ✅ All volume calculations
│   ├── ProgressTracker.swift ✅ Progress states & colors
│   └── ExerciseDataGrouper.swift ✅ Data grouping logic
├── Utilities/ (Shared helpers)
│   └── Formatters.swift ✅ All formatting functions
└── TestDataGenerator.swift (debug-only test data)
```

### 🏗️ **Architecture Principles:**

**1. Services** (`Services/`)
- **Purpose**: Pure business logic, calculations, data transformations
- **Rules**: Stateless classes with static methods OR @Observable classes
- **Examples**: Volume calculations, progress tracking, data grouping
- **Pattern**: 
```swift
@Observable
final class ServiceName {
    static func calculateSomething(input: Data) -> Result {
        // Pure business logic here
    }
}
```

**2. ViewModels** (`ViewModels/`)
- **Purpose**: Coordinate services, manage view state, handle user actions
- **Rules**: Use @Observable macro, inject ModelContext, delegate to services
- **Pattern**:
```swift
@Observable
final class ViewNameViewModel {
    private let context: ModelContext
    private let someService: SomeService
    
    var viewState: ViewState
    
    func handleUserAction() {
        let result = SomeService.doBusinessLogic(data)
        updateViewState(with: result)
    }
}
```

**3. Views** (`Views/`)
- **Purpose**: UI layout and presentation ONLY
- **Rules**: No business logic, delegate all actions to ViewModel
- **Pattern**:
```swift
struct ViewName: View {
    @Bindable var viewModel: ViewNameViewModel
    
    var body: some View {
        // Pure SwiftUI layout
        Button("Action") { viewModel.handleAction() }
    }
}
```

**4. Utilities** (`Utilities/`)
- **Purpose**: Shared helper functions, formatters, extensions
- **Rules**: Static functions, no state, pure functions
- **Pattern**:
```swift
enum UtilityName {
    static func formatSomething(_ input: Type) -> String {
        // Pure formatting logic
    }
}
```

### 📋 **When to Create New Files/Folders:**

**Create New Service When:**
- ✅ Adding complex business logic (>3 computed properties)
- ✅ Need calculations used by multiple views
- ✅ Adding new feature with data processing needs
- ✅ Logic exceeds ~100 lines

**Create New ViewModel When:**
- ✅ View has complex state management
- ✅ Need to coordinate multiple services
- ✅ Form handling or user interaction logic
- ✅ View needs >5 computed properties

**Create New Utility When:**
- ✅ Same formatting/helper code appears in 2+ places
- ✅ Adding new data transformation functions
- ✅ SwiftUI or SwiftData extensions

**Create New Folder When:**
- ✅ More than 5 files of the same type
- ✅ Adding new major feature area
- ✅ Clear logical grouping emerges

### 🎯 **Best Practices for New Development:**

**DO:**
- ✅ Extract business logic to Services immediately
- ✅ Keep Views under 200 lines
- ✅ Use ViewModels for state coordination
- ✅ Make Services testable with static methods
- ✅ Share utilities across the app
- ✅ Use @Observable macro for modern SwiftUI

**DON'T:**
- ❌ Put business logic in Views
- ❌ Create massive ViewModels (split into multiple services)
- ❌ Duplicate formatting logic
- ❌ Mix UI concerns with data processing
- ❌ Create tightly coupled dependencies

### 📈 **Migration Status:**
- ✅ **ExerciseDetailView**: REFACTORED (377→255 lines, clean architecture)
- ✅ **VolumeAnalytics**: EXTRACTED (all volume calculations)
- ✅ **ProgressTracker**: EXTRACTED (progress states & colors)
- ✅ **ExerciseDataGrouper**: EXTRACTED (data grouping logic)
- ✅ **Formatters**: EXTRACTED (all formatting utilities)
- ⚠️ **TestDataGenerator**: NEEDS SPLITTING (980 lines - too large)

### 🔄 **Future Refactoring Targets:**
1. **TestDataGenerator.swift** → Split into `TestData/` folder with multiple files
2. **Extensions/** → Create folder when we have SwiftUI/SwiftData extensions
3. **Cache/** → Add when implementing performance caching layer

### 🛠️ **Implementation Examples:**

**Adding a New Feature (e.g., Workout Analytics Dashboard):**

1. **Create Service First:**
```swift
// Services/WorkoutAnalytics.swift
@Observable
final class WorkoutAnalytics {
    static func calculateWeeklyStats(exercises: [Exercise]) -> WeeklyStats {
        // Business logic here
    }
    
    static func getTrendData(sets: [ExerciseSet], period: TimePeriod) -> [TrendPoint] {
        // More business logic
    }
}
```

2. **Create ViewModel for Coordination:**
```swift
// ViewModels/WorkoutDashboardViewModel.swift
@Observable
final class WorkoutDashboardViewModel {
    private let context: ModelContext
    
    var weeklyStats: WeeklyStats?
    var trendData: [TrendPoint] = []
    
    func loadAnalytics() {
        let exercises = fetchExercises()
        weeklyStats = WorkoutAnalytics.calculateWeeklyStats(exercises: exercises)
        trendData = WorkoutAnalytics.getTrendData(sets: fetchSets(), period: .month)
    }
}
```

3. **Create Clean View:**
```swift
// Views/WorkoutDashboardView.swift
struct WorkoutDashboardView: View {
    @Bindable var viewModel: WorkoutDashboardViewModel
    
    var body: some View {
        // Pure UI only - delegate all actions to viewModel
        VStack {
            if let stats = viewModel.weeklyStats {
                WeeklyStatsCard(stats: stats)
            }
            TrendChart(data: viewModel.trendData)
        }
        .onAppear { viewModel.loadAnalytics() }
    }
}
```

**Adding Shared Utilities:**
```swift
// Utilities/ChartHelpers.swift
enum ChartHelpers {
    static func generateChartPoints(from data: [DataPoint]) -> [ChartPoint] {
        // Reusable chart logic
    }
    
    static func formatAxisLabel(_ value: Double) -> String {
        // Reusable formatting
    }
}
```

**Extending Existing Services:**
```swift
// Services/VolumeAnalytics.swift - ADD new functions to existing service
extension VolumeAnalytics {
    static func calculateMonthlyVolume(from sets: [ExerciseSet]) -> [MonthlyVolume] {
        // New functionality in existing service
    }
}
```

### ⚡ **Quick Decision Guide:**

**"Where should this code go?"**
- **Business logic/calculations?** → `Services/`
- **View state management?** → `ViewModels/`
- **UI layout/presentation?** → `Views/`  
- **Shared formatting/helpers?** → `Utilities/`
- **Data models?** → `Models/` (keep simple)

**"Should I create a new file?"**
- **Service >100 lines?** → Split into focused services
- **View >200 lines?** → Extract subviews or simplify ViewModel  
- **ViewModel >150 lines?** → Split services or simplify coordination
- **Utility functions used in 2+ places?** → Extract to shared utility

## Debug Tools and Test Data

### TestDataGenerator
Available only in DEBUG builds, accessible via the ladybug menu in ExerciseListView:

**Test Data Sets:**
- **Set 1 (1 Month)**: 20 exercises, ~76 sets, realistic gym routine with progressive overload
- **Set 2 (1 Year)**: 50 exercises, ~150+ workouts, full year performance test data
- **Set 3 (2 Weeks)**: 5 basic exercises, 18 sets, simple testing data
- **Live Data**: 28 exercises, 119 sets from real gym sessions (Aug 17-22, 2025)

**Key Features:**
- `printCurrentData()`: Exports all workout data to console using `os.Logger`
- Preserves original category names (Biceps, Triceps, Shoulders, etc.) as free text
- Realistic timestamps and progressive overload patterns
- Background-compatible logging for device testing

**Usage:**
```swift
// In ExerciseListView debug menu
TestDataGenerator.generateTestDataSet4(modelContext: modelContext) // Live Data
TestDataGenerator.printCurrentData(modelContext: modelContext)    // Export to console
```

## SwiftData Performance Best Practices

### CRITICAL: Database-Level Operations Only
**NEVER load data into memory for filtering/sorting. ALWAYS use SwiftData predicates and descriptors.**

### Query Optimization Patterns

#### 1. Dynamic Query Construction (FASTEST)
```swift
// ✅ CORRECT - Database-level filtering
init(searchText: String) {
    if searchText.isEmpty {
        _exercises = Query(sort: [SortDescriptor(\.lastUpdated, order: .reverse)])
    } else {
        _exercises = Query(
            filter: #Predicate<Exercise> { 
                $0.name.localizedStandardContains(searchText) ||
                $0.category.localizedStandardContains(searchText)
            },
            sort: [SortDescriptor(\.lastUpdated, order: .reverse)]
        )
    }
}

// ❌ WRONG - In-memory filtering (SLOW)
var filteredExercises: [Exercise] {
    exercises.filter { $0.name.contains(searchText) }  // NEVER DO THIS
}
```

#### 2. Complex Predicates for Performance
```swift
// Compound predicates with AND/OR
@Query(filter: #Predicate<ExerciseSet> { set in
    set.weight > 100 && 
    set.reps >= 8 &&
    (set.exercise?.category == "Chest" || set.exercise?.category == "Back")
})
private var heavySets: [ExerciseSet]

// Date range queries (efficient)
let startDate = Date.now.addingTimeInterval(-7 * 24 * 60 * 60)
_recentSets = Query(
    filter: #Predicate<ExerciseSet> { $0.timestamp > startDate },
    sort: [SortDescriptor(\.timestamp, order: .reverse)]
)

// Relationship traversal (use optional chaining)
@Query(filter: #Predicate<ExerciseSet> { 
    $0.exercise?.lastUpdated > Date.now.addingTimeInterval(-86400)
})
private var todaysSets: [ExerciseSet]
```

#### 3. Pagination for Large Datasets
```swift
// Use FetchDescriptor with fetchLimit
let descriptor = FetchDescriptor<Exercise>(
    predicate: #Predicate { $0.category == category },
    sortBy: [SortDescriptor(\.lastUpdated, order: .reverse)]
)
descriptor.fetchLimit = 20  // Only load 20 at a time
descriptor.fetchOffset = currentPage * 20

let exercises = try modelContext.fetch(descriptor)
```

#### 4. Batch Operations (Required for Multi-Updates)
```swift
// ✅ CORRECT - Single transaction
modelContext.transaction {
    for exercise in exercises {
        exercise.bumpUpdated()
    }
}

// ❌ WRONG - Multiple save calls
for exercise in exercises {
    exercise.bumpUpdated()
    try? modelContext.save()  // NEVER save in a loop
}
```

#### 5. Background Context for Heavy Operations
```swift
// Create background context for intensive work
let container = modelContext.container
Task.detached(priority: .background) {
    let context = ModelContext(container)
    let descriptor = FetchDescriptor<ExerciseSet>()
    let sets = try context.fetch(descriptor)
    
    // Heavy computation here
    let stats = calculateStatistics(sets)
    
    // Update on main context
    await MainActor.run {
        updateCache(with: stats)
    }
}
```

### Indexing for Speed
```swift
@Model
final class Exercise {
    @Attribute(.unique) var id: UUID
    @Attribute(.spotlight) var name: String  // Indexed for search
    @Attribute(.spotlight) var category: String  // Indexed for filtering
    var lastUpdated: Date  // Consider indexing if frequently sorted
}
```

### Query Result Caching
```swift
@Observable
final class ExerciseCache {
    private var cache = [String: [Exercise]]()
    private var cacheTimestamps = [String: Date]()
    
    func getExercises(for category: String, context: ModelContext) -> [Exercise] {
        let key = category
        let now = Date()
        
        // Check cache validity (5 minute TTL)
        if let cached = cache[key],
           let timestamp = cacheTimestamps[key],
           now.timeIntervalSince(timestamp) < 300 {
            return cached
        }
        
        // Fetch from database
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate { $0.category == category }
        )
        let exercises = (try? context.fetch(descriptor)) ?? []
        
        // Update cache
        cache[key] = exercises
        cacheTimestamps[key] = now
        
        return exercises
    }
    
    func invalidate() {
        cache.removeAll()
        cacheTimestamps.removeAll()
    }
}
```

### Performance Anti-Patterns (NEVER DO THESE)

#### ❌ In-Memory Filtering
```swift
// NEVER filter after fetching
let filtered = exercises.filter { $0.name.contains(search) }
```

#### ❌ N+1 Query Problem
```swift
// WRONG - Triggers query for each exercise
for exercise in exercises {
    let setCount = exercise.sets.count  // Lazy loads each time
}

// CORRECT - Use aggregate query
let descriptor = FetchDescriptor<Exercise>()
// Include relationship in initial fetch
```

#### ❌ Synchronous Heavy Operations
```swift
// WRONG - Blocks UI
let stats = calculateHeavyStatistics(allSets)

// CORRECT - Use background queue
Task.detached { 
    let stats = calculateHeavyStatistics(allSets)
}
```

#### ❌ Unnecessary View Updates
```swift
// WRONG - Causes re-render on every change
@Query var allExercises: [Exercise]
var filtered: [Exercise] {
    allExercises.filter { ... }  // Recomputes on any exercise change
}

// CORRECT - Database-level filtering
@Query(filter: #Predicate<Exercise> { ... })
var filteredExercises: [Exercise]
```

### Performance Monitoring

#### Use Instruments Profiling
1. **Time Profiler**: Identify slow methods
2. **SwiftData Profiler**: Monitor query performance
3. **Memory Graph**: Detect retention cycles
4. **Main Thread Checker**: Find UI blocking operations

#### Add Performance Logging
```swift
let startTime = CFAbsoluteTimeGetCurrent()
let results = try context.fetch(descriptor)
let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
if timeElapsed > 0.016 {  // More than one frame (60fps)
    logger.warning("Slow query: \(timeElapsed * 1000)ms")
}
```

### Optimization Checklist
- [ ] All queries use #Predicate (database-level)
- [ ] No in-memory filtering or sorting
- [ ] Batch operations for multiple updates
- [ ] Background contexts for heavy work
- [ ] Indexed attributes for frequent queries
- [ ] Query result caching where appropriate
- [ ] Pagination for lists > 50 items
- [ ] Profile with Instruments before ship

## SwiftData + SwiftUI List Best Practices

### CRITICAL: ForEach Identity with Deletable Lists
**NEVER use array indices for ForEach when items can be deleted - causes SIGTERM crashes**

#### ❌ WRONG - Causes SIGTERM crashes during deletion
```swift
ForEach(sets.indices, id: \.self) { index in  
    let set = sets[index]  // Array positions change during deletion
    // ... row content
}
.onDelete(perform: delete)
```

**Problem**: When SwiftData updates the @Query after deletion, SwiftUI gets confused about which row is which because array indices shift. This causes diffing mismatches and SIGTERM crashes.

#### ✅ CORRECT - Use stable SwiftData identity
```swift
ForEach(sets, id: \.persistentModelID) { set in  
    // ... row content - each row has permanent unique ID
}
.onDelete(perform: delete)
```

### Deletion Best Practices
- **Use ONE deletion method**: Either `.onDelete()` OR `.swipeActions()`, never both
- **Wrap deletions in `withAnimation`** for smooth UI updates
- **Use existing delete functions** instead of direct context manipulation

#### Safe Deletion Pattern
```swift
private func delete(at offsets: IndexSet) {
    withAnimation {
        for i in offsets {
            context.delete(sets[i])
        }
        try? context.save()
    }
}
```

### ID Comparison Best Practices
When comparing SwiftData objects (e.g., for "first item" logic):
```swift
// ✅ CORRECT - Use persistentModelID
if set.persistentModelID == sets.first?.persistentModelID {
    // Show special UI for first item
}

// ❌ WRONG - Object identity can change with re-fetches
if set === sets.first {
    // May fail with SwiftData re-fetching
}
```

### Why This Matters
SwiftData automatically updates @Query results when data changes. If ForEach uses unstable identity (like array indices), SwiftUI's diffing algorithm cannot track which views correspond to which data items during mutations, leading to crashes.

## Important Notes
- Always consult latest documentation when implementing new features
- Performance is critical - measure before and after optimizations
- Use Instruments to profile performance bottlenecks
- Implement proper SwiftData error handling
- Consider memory usage with large datasets
- Use database-level filtering with #Predicate for search, not in-memory filtering

## SwiftUI Best Practices

### ForEach Identity Management
- Always use proper identity keys to avoid "Invalid frame dimension" warnings
- For arrays with stable indices, use `ForEach(array.indices, id: \.self)` pattern
- Avoid `Array(enumerated())` in ForEach as it can cause identity issues
- Example:
```swift
// ✅ Good - stable identity with indices
ForEach(sets.indices, id: \.self) { index in
    let set = sets[index]
    // Use set here
}

// ❌ Avoid - can cause frame dimension warnings  
ForEach(Array(sets.enumerated()), id: \.element) { (index, set) in
    // Identity issues with SwiftUI updates
}
```

## iOS 18 SwiftUI Regressions & Fixes

### Critical iOS 18 List Button Issue
**This is a documented iOS 18 regression that affects all SwiftUI apps.**

#### The Problem
- Buttons inside List/ForEach views don't respond to quick taps
- Only long presses work reliably
- Parent view gestures can completely block button actions
- This wastes hours of debugging time if you don't know about it

#### Required Fix Pattern
```swift
// ✅ CORRECT - iOS 18 Compatible Button in List
Button(action: doSomething) {
    Image(systemName: "plus.circle.fill")
        .font(.title2)
        .foregroundStyle(.tint)
}
.buttonStyle(.plain)  // CRITICAL: Use .plain, NOT .borderless
.contentShape(Rectangle())  // CRITICAL: Improves hit-testing

// ❌ WRONG - Won't work reliably in iOS 18
Button(action: doSomething) {
    Image(systemName: "plus.circle.fill")
}
.buttonStyle(.borderless)  // Unreliable in Lists
// Missing contentShape
```

#### Additional Requirements
- **Remove conflicting gestures:** Any parent `.onTapGesture` will block button taps
- **Test with quick taps:** Build succeeding doesn't mean buttons work
- **Check console logs:** If logs don't appear, it's a UI issue, not logic

#### Debugging Checklist for Non-Responsive Buttons
1. ✅ Is the button using `.buttonStyle(.plain)`?
2. ✅ Does it have `.contentShape(Rectangle())`?
3. ✅ Are there any parent `.onTapGesture` modifiers to remove?
4. ✅ Do console logs appear when tapping? (If not, it's hit-testing)
5. ✅ Are you testing with quick taps, not just long presses?

## Development Approach
- **INCREMENTAL DELIVERY**: Break down implementation into small, testable chunks
- Provide one feature or component at a time
- Allow testing and verification between each step
- Show progress gradually rather than delivering complete solutions
- Each code change should be functional and runnable
- Wait for feedback before proceeding to next step