//
//  LocationService.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI

@Observable
final class LocationService: NSObject {

    private(set) var authorizationStatus: CLAuthorizationStatus
    private(set) var currentLocation: CLLocation?
    private(set) var lastError: LocationError?

    var cameraPosition: MapCameraPosition = .automatic

    var isTrackingUser: Bool = true

    private(set) var isWorkoutTracking: Bool = false
    
    var onWorkoutLocationUpdate: ((CLLocation) -> Void)?

    private let manager: CLLocationManager

    enum LocationError: Error, LocalizedError {
        case permissionDenied
        case permissionRestricted
        case updateFailed(String)

        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Location access denied. Enable it in Settings to see yourself on the map."
            case .permissionRestricted:
                return "Location access restricted on this device."
            case .updateFailed(let message):
                return "Could not update location: \(message)"
            }
        }
    }


    override init() {
        manager = CLLocationManager()
        authorizationStatus = manager.authorizationStatus
        super.init()

        manager.delegate = self
        configureForPassiveUpdates()
    }

    private func configureForPassiveUpdates() {
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 25
        manager.pausesLocationUpdatesAutomatically = true
        manager.allowsBackgroundLocationUpdates = false
    }


    private func configureForWorkoutTracking() {
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.distanceFilter = 5
        manager.activityType = .fitness
        manager.pausesLocationUpdatesAutomatically = false
        manager.allowsBackgroundLocationUpdates = authorizationStatus == .authorizedAlways
    }

    func requestPermission() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied:
            lastError = .permissionDenied
        case .restricted:
            lastError = .permissionRestricted
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdating()
        @unknown default:
            break
        }
    }


    func requestAlwaysPermission() {
        guard authorizationStatus == .authorizedWhenInUse else { return }
        manager.requestAlwaysAuthorization()
    }

    func startUpdating() {
        guard isAuthorized else { return }
        if !isWorkoutTracking {
            configureForPassiveUpdates()
        }
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    
    func startWorkoutTracking() {
        guard isAuthorized else {
            requestPermission()
            return
        }
        isWorkoutTracking = true
        requestAlwaysPermission()
        configureForWorkoutTracking()
        manager.startUpdatingLocation()
    }


    func stopWorkoutTracking() {
        isWorkoutTracking = false
        configureForPassiveUpdates()
        manager.startUpdatingLocation()
    }

    func requestOneShotLocation() {
        guard isAuthorized else {
            requestPermission()
            return
        }
        manager.requestLocation()
    }

    func centerOnUser(distance: CLLocationDistance = 800) {
        guard let coordinate = currentLocation?.coordinate else { return }
        cameraPosition = .camera(
            MapCamera(centerCoordinate: coordinate, distance: distance)
        )
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
}


extension LocationService: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            lastError = nil
            if isWorkoutTracking {
                configureForWorkoutTracking()
            }
            startUpdating()
        case .denied:
            lastError = .permissionDenied
        case .restricted:
            lastError = .permissionRestricted
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        currentLocation = latest

        if isTrackingUser {
            cameraPosition = .camera(
                MapCamera(centerCoordinate: latest.coordinate, distance: 800)
            )
        }

        if isWorkoutTracking {
            onWorkoutLocationUpdate?(latest)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastError = .updateFailed(error.localizedDescription)
    }
}
