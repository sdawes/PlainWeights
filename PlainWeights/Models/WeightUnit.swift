//
//  WeightUnit.swift
//  PlainWeights
//
//  Weight unit enum for kg/lbs conversion
//

import Foundation

enum WeightUnit: String, CaseIterable {
    case kg = "kg"
    case lbs = "lbs"

    /// Unit suffix for display (e.g., "60kg" or "132lbs")
    var displayName: String {
        rawValue
    }

    /// Whether this is a metric unit
    var isMetric: Bool {
        self == .kg
    }

    /// Conversion factor from kg to this unit
    var conversionFactor: Double {
        switch self {
        case .kg: return 1.0
        case .lbs: return 2.20462
        }
    }

    /// Convert kg value to this unit for display
    func fromKg(_ kg: Double) -> Double {
        kg * conversionFactor
    }

    /// Convert value in this unit back to kg for storage
    func toKg(_ value: Double) -> Double {
        value / conversionFactor
    }
}
