//
//  Exercise.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 16/08/2025.
//

import Foundation
import SwiftData

@Model
final class Exercise {
    var id = UUID()
    var name: String
    var category: String
    var createdDate: Date
    
    init(name: String, category: String, createdDate: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.createdDate = createdDate
    }
}