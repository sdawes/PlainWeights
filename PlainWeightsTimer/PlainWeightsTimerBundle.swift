//
//  PlainWeightsTimerBundle.swift
//  PlainWeightsTimer
//
//  Created by Stephen Dawes on 13/04/2026.
//

import WidgetKit
import SwiftUI

@main
struct PlainWeightsTimerBundle: WidgetBundle {
    var body: some Widget {
        PlainWeightsTimer()
        PlainWeightsTimerControl()
        PlainWeightsTimerLiveActivity()
    }
}
