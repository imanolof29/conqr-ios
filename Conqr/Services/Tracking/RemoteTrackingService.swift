//
//  RemoteTrackingService.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

protocol RemoteTrackingServicing {
    func listWorkouts() async throws -> [WorkoutDTO]
    func getWorkoutById(id: String) async throws -> WorkoutDTO
}

struct RemoteTrackingService: RemoteTrackingServicing {
    
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func listWorkouts() async throws -> [WorkoutDTO] {
        let requestModel = APIRequest<[WorkoutDTO]>(method: .get, path: TrackingEndpoint.workouts.path)
        return try await client.execute(requestModel)
    }
    
    func getWorkoutById(id: String) async throws -> WorkoutDTO {
        let requestModel = APIRequest<WorkoutDTO>(method: .get, path: TrackingEndpoint.workout(id: id).path)
        return try await client.execute(requestModel)
    }
    
}
