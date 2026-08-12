//
//  WorkoutTracker.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation
import CoreLocation
import SwiftData


@Observable
final class WorkoutTracker {

    private(set) var activeActivity: ActivityRecord?

    var isActive: Bool { activeActivity != nil }

    private let locationService: LocationService
    private let modelContext: ModelContext

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
    }

    func finish() {
        guard let activeActivity else { return }

        locationService.stopWorkoutTracking()

        activeActivity.finish()
        try? modelContext.save()

        self.activeActivity = nil
    }

    private func record(_ location: CLLocation) {
        guard let activeActivity else { return }
        activeActivity.addLocation(location)
    }
}
