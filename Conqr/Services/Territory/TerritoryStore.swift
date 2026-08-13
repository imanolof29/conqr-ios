//
//  TerritoryStore.swift
//  Conqr
//
//  Created by Imanol Ortiz on 13/08/2026.
//

import Foundation
import MapKit

@MainActor
@Observable
final class TerritoryStore {
    private(set) var all: [TerritoryDTO] = []
    private(set) var hasFetched = false
    private(set) var lastError: String?

    private let service: RemoteTerritoryServicing
    private var lastRegion: MKCoordinateRegion?
    private var refreshTask: Task<Void, Never>?

    init(service: RemoteTerritoryServicing) {
        self.service = service
    }

    func refresh(for region: MKCoordinateRegion) {
        lastRegion = region
        refreshTask?.cancel()

        refreshTask = Task { [weak self, service] in
            guard let self else { return }
            let bounds = region.bounds
            do {
                let territories = try await service.getTerritories(
                    minLat: bounds.minLat,
                    minLng: bounds.minLng,
                    maxLat: bounds.maxLat,
                    maxLng: bounds.maxLng
                )
                guard !Task.isCancelled else { return }
                self.all = territories
                self.hasFetched = true
                self.lastError = nil
            } catch {
                guard !Task.isCancelled else { return }
                self.lastError = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
            }
        }
    }

    func refreshCurrentRegion() {
        guard let lastRegion else { return }
        refresh(for: lastRegion)
    }
}

private extension MKCoordinateRegion {
    var bounds: (minLat: Double, minLng: Double, maxLat: Double, maxLng: Double) {
        (
            minLat: center.latitude - span.latitudeDelta / 2,
            minLng: center.longitude - span.longitudeDelta / 2,
            maxLat: center.latitude + span.latitudeDelta / 2,
            maxLng: center.longitude + span.longitudeDelta / 2
        )
    }
}
