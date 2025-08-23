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

### View Layer
- Use `NavigationStack` with value-based navigation
- Implement `.task` modifier for async data loading
- Use `@State` and `@Binding` properly to minimize re-renders
- Leverage `ViewThatFits` for responsive layouts
- Use `.sensoryFeedback` for haptic feedback

### Data Layer
- SwiftData models with proper relationships
- Implement custom `FetchDescriptor` for complex queries
- Use `@Query` animations for smooth updates
- Background `ModelContext` for intensive operations
- Implement proper migration schemas

### Charts and Analytics
- Pre-calculate and cache chart data points
- Use `ChartProxy` for interactive features
- Implement data windowing for large datasets
- Background queue for statistical calculations
- Consider using `TimelineView` for real-time updates

### Performance Patterns
```swift
// Example patterns to follow:
// 1. Use @Query with predicates
@Query(filter: #Predicate<Exercise> { $0.category == "Chest" })
private var chestExercises: [Exercise]

// 2. Batch operations
modelContext.transaction {
    // Multiple operations
}

// 3. Background processing
Task.detached(priority: .background) {
    // Heavy calculations
}

// 4. Cached computed properties
@Observable
final class MetricsCache {
    private var cache: [String: Any] = [:]
    // Implement cache invalidation
}
```

### Key Files Structure
- **Models/**: SwiftData models (Exercise, ExerciseSet, WorkoutSession)
  - Exercise model includes lastUpdated tracking and bumpUpdated() helper
  - ExerciseSet automatically updates parent Exercise.lastUpdated
- **Views/**: SwiftUI views organized by feature
  - ExerciseListView has efficient SwiftData-powered search with .searchable
  - FilteredExerciseListView uses dynamic Query with #Predicate for database-level filtering
  - Searches both exercise name and category using localizedStandardContains
  - Maintains SortDescriptor to order by lastUpdated (most recent first)
  - ExerciseDetailView has Apple Notes-style inline name editing
- **ViewModels/**: `@Observable` view models for complex logic
- **Services/**: Data aggregation and chart data services
- **Cache/**: Performance caching layer
- **Extensions/**: SwiftData and SwiftUI extensions
- **TestDataGenerator.swift**: Debug-only test data generation for development and testing

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

## Development Approach
- **INCREMENTAL DELIVERY**: Break down implementation into small, testable chunks
- Provide one feature or component at a time
- Allow testing and verification between each step
- Show progress gradually rather than delivering complete solutions
- Each code change should be functional and runnable
- Wait for feedback before proceeding to next step