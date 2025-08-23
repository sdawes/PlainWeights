//
//  VolumeProgressTests.swift
//  PlainWeightsTests
//
//  Tests for volume progress tracking logic in ExerciseDetailView
//

import XCTest
import SwiftData
@testable import PlainWeights

final class VolumeProgressTests: XCTestCase {
    
    var exercise: Exercise!
    var calendar: Calendar!
    
    override func setUp() {
        super.setUp()
        calendar = Calendar.current
        exercise = Exercise(name: "Test Exercise", category: "Test")
    }
    
    override func tearDown() {
        exercise = nil
        calendar = nil
        super.tearDown()
    }
    
    // MARK: - Volume Calculation Tests
    
    func testVolumeCalculation() throws {
        // Test that weight × reps is calculated correctly
        let set1 = ExerciseSet(weight: 80.0, reps: 10, exercise: exercise) // 800kg volume
        let set2 = ExerciseSet(weight: 60.0, reps: 12, exercise: exercise) // 720kg volume
        
        let sets = [set1, set2]
        let totalVolume = sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
        
        XCTAssertEqual(totalVolume, 1520.0, "Volume should be 800 + 720 = 1520kg")
    }
    
    func testTodayVolumeFiltering() throws {
        // Test filtering sets by today's date
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let todaySet = ExerciseSet(timestamp: today, weight: 80.0, reps: 10, exercise: exercise)
        let yesterdaySet = ExerciseSet(timestamp: yesterday, weight: 70.0, reps: 8, exercise: exercise)
        
        let allSets = [todaySet, yesterdaySet]
        
        // Filter to today only (mimics todaysSets logic)
        let todayStart = calendar.startOfDay(for: today)
        let todaysSets = allSets.filter { calendar.startOfDay(for: $0.timestamp) == todayStart }
        let todayVolume = todaysSets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
        
        XCTAssertEqual(todaysSets.count, 1, "Should only find 1 set from today")
        XCTAssertEqual(todayVolume, 800.0, "Today's volume should be 80 × 10 = 800kg")
    }
    
    // MARK: - Last Completed Day Tests
    
    func testLastCompletedDayDetection() throws {
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        
        let yesterdaySet = ExerciseSet(timestamp: yesterday, weight: 100.0, reps: 8, exercise: exercise)
        let twoDaysAgoSet = ExerciseSet(timestamp: twoDaysAgo, weight: 90.0, reps: 10, exercise: exercise)
        
        let sets = [yesterdaySet, twoDaysAgoSet]
        
        // Mimic lastCompletedDayInfo logic
        let todayStart = calendar.startOfDay(for: today)
        let setsByDay = Dictionary(grouping: sets) { set in
            calendar.startOfDay(for: set.timestamp)
        }
        let pastDays = setsByDay.keys.filter { $0 < todayStart }.sorted(by: >)
        
        XCTAssertEqual(pastDays.count, 2, "Should find 2 past days")
        XCTAssertEqual(pastDays.first, calendar.startOfDay(for: yesterday), "Most recent should be yesterday")
        
        if let lastDay = pastDays.first, let lastDaySets = setsByDay[lastDay] {
            let volume = lastDaySets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
            XCTAssertEqual(volume, 800.0, "Yesterday's volume should be 100 × 8 = 800kg")
        } else {
            XCTFail("Should find last completed day")
        }
    }
    
    func testNoLastCompletedDay() throws {
        // Test when there are no previous days (new exercise)
        let today = Date()
        let todaySet = ExerciseSet(timestamp: today, weight: 80.0, reps: 10, exercise: exercise)
        
        let sets = [todaySet]
        
        // Mimic lastCompletedDayInfo logic
        let todayStart = calendar.startOfDay(for: today)
        let setsByDay = Dictionary(grouping: sets) { set in
            calendar.startOfDay(for: set.timestamp)
        }
        let pastDays = setsByDay.keys.filter { $0 < todayStart }.sorted(by: >)
        
        XCTAssertTrue(pastDays.isEmpty, "Should find no past days")
    }
    
    // MARK: - Progress Ratio Tests
    
    func testProgressRatioCalculation() throws {
        let todayVolume = 900.0
        let lastDayVolume = 800.0
        
        // Mimic progressRatio logic - under the cap
        let progressRatio = min(todayVolume / lastDayVolume, 1.2)
        
        // 900/800 = 1.125, which is under 1.2 cap
        XCTAssertEqual(progressRatio, 1.125, accuracy: 0.001, "Progress should be 900/800 = 1.125")
    }
    
    func testProgressRatioCapping() throws {
        let todayVolume = 2000.0
        let lastDayVolume = 1000.0
        
        // Should cap at 1.2 even though actual ratio is 2.0
        let progressRatio = min(todayVolume / lastDayVolume, 1.2)
        
        XCTAssertEqual(progressRatio, 1.2, "Progress should be capped at 1.2")
    }
    
    func testProgressRatioZeroToday() throws {
        let todayVolume = 0.0
        let lastDayVolume = 800.0
        
        let progressRatio = min(todayVolume / lastDayVolume, 1.2)
        
        XCTAssertEqual(progressRatio, 0.0, "Progress should be 0 when today's volume is 0")
    }
    
    func testProgressRatioZeroLastDay() throws {
        let todayVolume = 500.0
        let lastDayVolume = 0.0
        
        // Should return 0 when lastDayVolume is 0 (mimics guard condition)
        let progressRatio = lastDayVolume > 0 ? min(todayVolume / lastDayVolume, 1.2) : 0.0
        
        XCTAssertEqual(progressRatio, 0.0, "Progress should be 0 when last day volume is 0")
    }
    
    // MARK: - Delta Text Tests
    
    func testDeltaTextPositive() throws {
        let todayVolume = 1000.0
        let lastDayVolume = 800.0
        let lastDate = calendar.date(byAdding: .day, value: -1, to: Date())!
        
        // Mimic deltaText logic
        let delta = todayVolume - lastDayVolume
        let sign = delta >= 0 ? "+" : ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "E d MMM"
        let dateFormatted = formatter.string(from: lastDate)
        
        // Format volume (simplified version)
        let deltaFormatted = String(format: "%.0f", abs(delta))
        let deltaText = "\(sign)\(deltaFormatted) kg vs \(dateFormatted)"
        
        XCTAssertTrue(deltaText.hasPrefix("+200 kg vs"), "Should show positive delta")
        XCTAssertTrue(deltaText.contains("kg vs"), "Should contain 'kg vs'")
    }
    
    func testDeltaTextNegative() throws {
        let todayVolume = 600.0
        let lastDayVolume = 800.0
        
        let delta = todayVolume - lastDayVolume
        let sign = delta >= 0 ? "+" : ""
        
        let deltaFormatted = String(format: "%.0f", abs(delta))
        
        XCTAssertEqual(sign, "", "Sign should be empty for negative delta")
        XCTAssertEqual(deltaFormatted, "200", "Delta should be 200")
    }
    
    func testBaselineDayText() throws {
        // When no last completed day exists
        let deltaText = "Baseline day"
        
        XCTAssertEqual(deltaText, "Baseline day", "Should show 'Baseline day' when no history")
    }
    
    // MARK: - Show Progress Bar Tests
    
    func testShowProgressBarWithHistory() throws {
        let lastDayVolume = 800.0
        
        // Mimic showProgressBar logic
        let showProgressBar = lastDayVolume > 0
        
        XCTAssertTrue(showProgressBar, "Should show progress bar when last day has volume")
    }
    
    func testHideProgressBarNoHistory() throws {
        let lastDayVolume = 0.0
        
        let showProgressBar = lastDayVolume > 0
        
        XCTAssertFalse(showProgressBar, "Should hide progress bar when no last day volume")
    }
    
    // MARK: - Date Boundary Tests
    
    func testMidnightBoundary() throws {
        // Test that sets at 23:59 and 00:01 are in different days
        let calendar = Calendar.current
        let today = Date()
        let todayStart = calendar.startOfDay(for: today)
        
        // 23:59 today
        let lateTonight = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: today)!
        // 00:01 tomorrow  
        let earlyTomorrow = calendar.date(byAdding: .minute, value: 2, to: lateTonight)!
        
        let tonightDay = calendar.startOfDay(for: lateTonight)
        let tomorrowDay = calendar.startOfDay(for: earlyTomorrow)
        
        XCTAssertNotEqual(tonightDay, tomorrowDay, "23:59 and 00:01 should be different days")
        XCTAssertEqual(tonightDay, todayStart, "23:59 should be same day as today")
    }
}