//
//  KeyboardUtility.swift
//  PlainWeights
//
//  Created for managing keyboard dismissal across the app
//

import SwiftUI

enum KeyboardUtility {

    /// Dismisses the keyboard by resigning first responder
    /// Can be called from any view or service in the app
    static func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}