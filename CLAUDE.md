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

### Performance Priorities
- All data operations must be optimized for speed
- Implement aggressive caching strategies for computed metrics
- Use lazy loading and pagination for large datasets
- Minimize view re-renders using computed properties and `@Observable` macro
- Background processing for heavy calculations
- Batch operations for data updates

### Data Model Architecture

#### Core Entities
- **Exercise**: Name, category (enum: chest, back, legs, shoulders, arms, core, cardio)
- **WorkoutSession**: Date, exercises performed
- **Set**: Reps, weight, exercise reference, timestamp
- **Metrics**: Cached/computed statistics for performance

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
# Build for Debug configuration
xcodebuild -scheme PlainWeights -configuration Debug build

# Build for Release configuration  
xcodebuild -scheme PlainWeights -configuration Release build

# Clean build folder
xcodebuild -scheme PlainWeights clean
```

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
@Query(filter: #Predicate<Exercise> { $0.category == .chest })
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
- **Models/**: SwiftData models (Exercise, Set, WorkoutSession)
- **Views/**: SwiftUI views organized by feature
- **ViewModels/**: `@Observable` view models for complex logic
- **Services/**: Data aggregation and chart data services
- **Cache/**: Performance caching layer
- **Extensions/**: SwiftData and SwiftUI extensions

## Important Notes
- Always consult latest documentation when implementing new features
- Performance is critical - measure before and after optimizations
- Use Instruments to profile performance bottlenecks
- Implement proper SwiftData error handling
- Consider memory usage with large datasets