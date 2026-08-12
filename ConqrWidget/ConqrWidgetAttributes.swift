//
//  ConqrWidgetAttributes.swift
//  ConqrWidget
//
//  Created by Imanol Ortiz on 12/08/2026.
//
//  Shared between the Conqr app target and the ConqrWidget extension target
//  so both can create/update/end the same Live Activity.

import ActivityKit
import AppIntents
import Foundation

struct ConqrWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {}

    var activityType: ActivityType
    var startDate: Date
}


enum WorkoutFinishBridge {
    static var handler: (() -> Void)?
}

struct FinishWorkoutIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Finalizar entreno"
    static var description = IntentDescription("Finaliza el entreno activo y cierra la Live Activity.")

    @MainActor
    func perform() async throws -> some IntentResult {
        if let handler = WorkoutFinishBridge.handler {
            handler()
        } else {
            for activity in Activity<ConqrWidgetAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
        return .result()
    }
}
