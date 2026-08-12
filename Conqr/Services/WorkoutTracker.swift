//
//  WorkoutTracker.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation
import CoreLocation
import SwiftData
import ActivityKit


@Observable
final class WorkoutTracker {

    private(set) var activeActivity: ActivityRecord?

    var isActive: Bool { activeActivity != nil }

    private let locationService: LocationService
    private let modelContext: ModelContext
    private var liveActivity: Activity<ConqrWidgetAttributes>?

    init(locationService: LocationService, modelContext: ModelContext) {
        self.locationService = locationService
        self.modelContext = modelContext

        locationService.onWorkoutLocationUpdate = { [weak self] location in
            self?.record(location)
        }
    }

    func start(type: ActivityType) {
        guard activeActivity == nil else { return }

        let activity = ActivityRecord(type: type)
        modelContext.insert(activity)
        activeActivity = activity

        locationService.startWorkoutTracking()
        startLiveActivity(type: type, startDate: activity.startDate)
    }

    func finish() {
        guard let activeActivity else { return }

        locationService.stopWorkoutTracking()

        activeActivity.finish()
        try? modelContext.save()

        self.activeActivity = nil
        endLiveActivity()
    }

    private func record(_ location: CLLocation) {
        guard let activeActivity else { return }
        activeActivity.addLocation(location)
    }

    private func startLiveActivity(type: ActivityType, startDate: Date) {
        WorkoutFinishBridge.handler = { [weak self] in self?.finish() }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = ConqrWidgetAttributes(activityType: type, startDate: startDate)
        let content = ActivityContent(state: ConqrWidgetAttributes.ContentState(), staleDate: nil)

        liveActivity = try? Activity.request(attributes: attributes, content: content)
    }

    private func endLiveActivity() {
        WorkoutFinishBridge.handler = nil

        let activity = liveActivity
        liveActivity = nil

        Task {
            await activity?.end(nil, dismissalPolicy: .immediate)
        }
    }
}
