//
//  RemoteTrackingService.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

protocol RemoteTrackingServicing {
    func listWorkouts() async throws -> [WorkoutDTO]
}

struct RemoteTrackingService: RemoteTrackingServicing {
    private let client: APIClientProtocol

    init(client: APIClientProtocol = APIClient(
        baseURL: APIEnvironment.baseURL,
        tokenProvider: { KeychainTokenStore().accessToken }
    )) {
        self.client = client
    }

    func listWorkouts() async throws -> [WorkoutDTO] {
        let requestModel = APIRequest<[WorkoutDTO]>(method: .get, route: .tracking(.workouts))
        return try await client.execute(requestModel)
    }
}
