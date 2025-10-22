//
//  IconComponents.swift
//  PlainWeights
//
//  Created by Claude on 27/09/2025.
//

import SwiftUI

/// Reusable icon components with consistent styling
enum IconComponents {

    /// Delete icon - just trash symbol in red
    static func deleteIcon(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "trash")
                .font(.callout.bold())
                .foregroundColor(.red)
        }
    }
}