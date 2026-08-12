//
//  ActivityRecord.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation
import CoreLocation
import MapKit
import SwiftData


@Model
class ActivityRecord {
    var id: UUID
    var type: String
    var statusRaw: String
    var startDate: Date
    var endDate: Date?
    var duration: TimeInterval
    var distance: Double

    var synced: Bool
    var syncedAt: Date?
    var remoteID: String?

    @Relationship(deleteRule: .cascade, inverse: \RouteLocation.activity)
    var locations: [RouteLocation] = []

    init(
        type: ActivityType,
        startDate: Date = .now,
        endDate: Date? = nil,
        duration: TimeInterval = 0,
        distance: Double = 0,
        status: ActivityStatus = .inProgress,
        synced: Bool = false
    ) {
        self.id = UUID()
        self.type = type.rawValue
        self.statusRaw = status.rawValue
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.distance = distance
        self.synced = synced
    }

    var activityType: ActivityType {
        get { ActivityType(rawValue: type) ?? .walk }
        set { type = newValue.rawValue }
    }

    var status: ActivityStatus {
        get { ActivityStatus(rawValue: statusRaw) ?? .inProgress }
        set { statusRaw = newValue.rawValue }
    }

    var orderedLocations: [RouteLocation] {
        locations.sorted { $0.sequence < $1.sequence }
    }

    var coordinates: [CLLocationCoordinate2D] {
        orderedLocations.map(\.coordinate)
    }

    var polyline: MKPolyline {
        MKPolyline(coordinates: coordinates, count: coordinates.count)
    }

    var formattedDistance: String {
        let measurement = Measurement(value: distance, unit: UnitLength.meters)
        return measurement.formatted(
            .measurement(width: .abbreviated, usage: .road, numberFormatStyle: .number.precision(.fractionLength(0...2)))
        )
    }

    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = duration >= 3600 ? [.hour, .minute, .second] : [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? "0:00"
    }

    @discardableResult
    func addLocation(_ location: CLLocation) -> RouteLocation {
        if let last = orderedLocations.last {
            distance += location.distance(from: last.clLocation)
        }
        let point = RouteLocation(sequence: locations.count, location: location)
        point.activity = self
        locations.append(point)
        return point
    }

    func finish(at date: Date = .now) {
        endDate = date
        duration = date.timeIntervalSince(startDate)
        status = .completed
    }

    func markSynced(remoteID: String? = nil, at date: Date = .now) {
        synced = true
        syncedAt = date
        if let remoteID {
            self.remoteID = remoteID
        }
    }
}
