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
    private(set) var lastConquest: TerritoryConqueredPayload?

    var isActive: Bool { activeActivity != nil }

    private let locationService: LocationService
    private let modelContext: ModelContext
    private let trackingSocket: TrackingSocketServicing
    private let remoteTrackingService: RemoteTrackingServicing
    private var liveActivity: Activity<ConqrWidgetAttributes>?

    private var remoteWorkoutId: String?
    private var pointSequence: Int = 0

    init(
        locationService: LocationService,
        modelContext: ModelContext,
        trackingSocket: TrackingSocketServicing = TrackingSocketService(),
        remoteTrackingService: RemoteTrackingServicing = RemoteTrackingService(
            client: APIClient(baseURL: APIEnvironment.baseURL, tokenProvider: { KeychainTokenStore().accessToken })
        )
    ) {
        self.locationService = locationService
        self.modelContext = modelContext
        self.trackingSocket = trackingSocket
        self.remoteTrackingService = remoteTrackingService

        locationService.onWorkoutLocationUpdate = { [weak self] location in
            self?.record(location)
        }

        trackingSocket.onTerritoryConquered = { [weak self] conquest in
            self?.lastConquest = conquest
        }

        trackingSocket.onServerError = { [weak self] message in
            self?.connectionError = message
        }
    }

    func start(type: ActivityType) {
        guard activeActivity == nil else { return }

        let activity = ActivityRecord(type: type)
        modelContext.insert(activity)
        activeActivity = activity
        remoteWorkoutId = nil
        pointSequence = 0
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

        Task { [trackingSocket, remoteTrackingService, modelContext] in
            defer { trackingSocket.disconnect() }

            guard let remoteWorkoutId else { return }
            do {
                let payload = try await remoteTrackingService.finishWorkout(id: remoteWorkoutId)
                activity.markSynced(remoteID: payload.id)
                try? modelContext.save()
            } catch {

            }
        }
    }

    private func record(_ location: CLLocation) {
        guard let activeActivity else { return }
        activeActivity.addLocation(location)

        if let remoteWorkoutId {
            pointSequence += 1
            trackingSocket.sendLocation(
                workoutId: remoteWorkoutId,
                sequence: pointSequence,
                timestamp: location.timestamp,
                lat: location.coordinate.latitude,
                lng: location.coordinate.longitude,
                accuracy: location.horizontalAccuracy >= 0 ? location.horizontalAccuracy : nil
            )
        }
    }

    private func connectRemote(for activity: ActivityRecord) {
        Task { [weak self, trackingSocket, remoteTrackingService] in
            guard let self else { return }
            do {
                try await trackingSocket.connect()
                let workout = try await remoteTrackingService.startWorkout(activityType: activity.activityType)
                guard self.activeActivity === activity else { return } // finished/cancelled meanwhile
                self.remoteWorkoutId = workout.id
                activity.remoteID = workout.id
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
