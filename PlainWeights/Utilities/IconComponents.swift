//
//  IconComponents.swift
//  PlainWeights
//
//  Created by Claude on 27/09/2025.
//

import SwiftUI

/// Reusable icon components with consistent styling
enum IconComponents {

    /// Circular delete icon with dark red background and white trash icon
    static func deleteIcon(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "trash")
                .font(.caption2)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color(red: 0.7, green: 0.1, blue: 0.1))
                .clipShape(Circle())
        }
    }
}