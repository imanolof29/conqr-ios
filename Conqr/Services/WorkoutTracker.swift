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
    private(set) var connectionError: String?

    var isActive: Bool { activeActivity != nil }

    private let locationService: LocationService
    private let modelContext: ModelContext
    private let trackingSocket: TrackingSocketServicing
    private var liveActivity: Activity<ConqrWidgetAttributes>?

    private var remoteWorkoutId: String?

    init(
        locationService: LocationService,
        modelContext: ModelContext,
        trackingSocket: TrackingSocketServicing = TrackingSocketService()
    ) {
        self.locationService = locationService
        self.modelContext = modelContext
        self.trackingSocket = trackingSocket

        locationService.onWorkoutLocationUpdate = { [weak self] location in
            self?.record(location)
        }

        trackingSocket.onPointAck = { [weak self] distanceMeters in
            self?.activeActivity?.distance = distanceMeters
        }
    }

    func start(type: ActivityType) {
        guard activeActivity == nil else { return }

        let activity = ActivityRecord(type: type)
        modelContext.insert(activity)
        activeActivity = activity
        remoteWorkoutId = nil
        connectionError = nil

        locationService.startWorkoutTracking()
        startLiveActivity(type: type, startDate: activity.startDate)
        connectRemote(for: activity)
    }

    func finish() {
        guard let activity = activeActivity else { return }

        locationService.stopWorkoutTracking()
        endLiveActivity()

        activity.finish()
        try? modelContext.save()
        activeActivity = nil

        let remoteWorkoutId = self.remoteWorkoutId
        self.remoteWorkoutId = nil
        guard let remoteWorkoutId else { return }

        Task { [trackingSocket, modelContext] in
            do {
                let payload = try await trackingSocket.finishWorkout(workoutId: remoteWorkoutId)
                activity.distance = payload.distanceMeters
                activity.markSynced(remoteID: payload.workoutId)
                try? modelContext.save()
            } catch {

            }
        }
    }

    private func record(_ location: CLLocation) {
        guard let activeActivity else { return }
        activeActivity.addLocation(location)

        if let remoteWorkoutId {
            trackingSocket.sendPoint(
                workoutId: remoteWorkoutId,
                lat: location.coordinate.latitude,
                lng: location.coordinate.longitude
            )
        }
    }

    private func connectRemote(for activity: ActivityRecord) {
        Task { [weak self, trackingSocket] in
            guard let self else { return }
            do {
                let workoutId = try await trackingSocket.startWorkout()
                guard self.activeActivity === activity else { return } // finished/cancelled meanwhile
                self.remoteWorkoutId = workoutId
                activity.remoteID = workoutId
            } catch {
                guard self.activeActivity === activity else { return }
                self.connectionError = (error as? TrackingSocketError)?.errorDescription ?? error.localizedDescription
            }
        }
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
