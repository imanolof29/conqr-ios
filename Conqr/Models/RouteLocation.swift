//
//  RouteLocation.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation
import CoreLocation
import SwiftData


@Model
class RouteLocation {
    var id: UUID
    var sequence: Int
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var horizontalAccuracy: Double
    var speed: Double
    var course: Double
    var timestamp: Date

    var activity: ActivityRecord?

    init(
        sequence: Int,
        coordinate: CLLocationCoordinate2D,
        altitude: Double = 0,
        horizontalAccuracy: Double = -1,
        speed: Double = -1,
        course: Double = -1,
        timestamp: Date = .now
    ) {
        self.id = UUID()
        self.sequence = sequence
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.speed = speed
        self.course = course
        self.timestamp = timestamp
    }

    convenience init(sequence: Int, location: CLLocation) {
        self.init(
            sequence: sequence,
            coordinate: location.coordinate,
            altitude: location.altitude,
            horizontalAccuracy: location.horizontalAccuracy,
            speed: location.speed,
            course: location.course,
            timestamp: location.timestamp
        )
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var clLocation: CLLocation {
        CLLocation(
            coordinate: coordinate,
            altitude: altitude,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: -1,
            course: course,
            speed: speed,
            timestamp: timestamp
        )
    }
}
