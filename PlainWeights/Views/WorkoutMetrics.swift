//
//  WorkoutMetrics.swift
//  PlainWeights
//
//  Created by Claude on 27/09/2025.
//

import SwiftUI

struct WorkoutMetrics: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Empty for now - no text content
        }
        .frame(maxWidth: .infinity, minHeight: 80)  // Give it some height
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
        .listRowSeparator(.hidden)
        .padding(.vertical, 8)
    }
}

#Preview {
    WorkoutMetrics()
        .padding()
}