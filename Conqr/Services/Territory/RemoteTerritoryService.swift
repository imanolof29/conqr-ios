//
//  RemoteTerritoryService.swift
//  Conqr
//
//  Created by Imanol Ortiz on 13/08/2026.
//

import Foundation

protocol RemoteTerritoryServicing {
    func getTerritories(minLat: Double, minLng: Double, maxLat: Double, maxLng: Double) async throws -> [TerritoryDTO]
}

struct RemoteTerritoryService: RemoteTerritoryServicing {

    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol) {
        self.client = client
    }

    func getTerritories(minLat: Double, minLng: Double, maxLat: Double, maxLng: Double) async throws -> [TerritoryDTO] {
        try await client.execute(
            TerritoriesInBoundsEndpoint(minLat: minLat, minLng: minLng, maxLat: maxLat, maxLng: maxLng)
        )
    }
}

private struct TerritoriesInBoundsEndpoint: Endpoint {
    typealias Response = [TerritoryDTO]

    let minLat: Double
    let minLng: Double
    let maxLat: Double
    let maxLng: Double

    var path: String { "/territories" }
    var method: HTTPMethod { .get }
    var requiresAuth: Bool { true }

    var queryItems: [URLQueryItem]? {
        [
            URLQueryItem(name: "minLat", value: String(minLat)),
            URLQueryItem(name: "minLng", value: String(minLng)),
            URLQueryItem(name: "maxLat", value: String(maxLat)),
            URLQueryItem(name: "maxLng", value: String(maxLng))
        ]
    }
}
