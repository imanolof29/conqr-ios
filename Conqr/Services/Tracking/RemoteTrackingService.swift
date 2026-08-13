//
//  RemoteTrackingService.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

protocol RemoteTrackingServicing {
    func startWorkout(activityType: ActivityType) async throws -> WorkoutDTO
    func getWorkoutById(id: String) async throws -> WorkoutDTO
    func finishWorkout(id: String) async throws -> WorkoutDTO
}

struct RemoteTrackingService: RemoteTrackingServicing {

    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func startWorkout(activityType: ActivityType) async throws -> WorkoutDTO {
        let requestModel = try APIRequest<WorkoutDTO>(
            method: .post,
            path: TrackingEndpoint.workouts.path,
            body: CreateWorkoutRequestDTO(activityType: activityType.remoteValue)
        )
        return try await client.execute(requestModel)
    }

    func getWorkoutById(id: String) async throws -> WorkoutDTO {
        let requestModel = APIRequest<WorkoutDTO>(method: .get, path: TrackingEndpoint.workout(id: id).path)
        return try await client.execute(requestModel)
    }

    func finishWorkout(id: String) async throws -> WorkoutDTO {
        let requestModel = APIRequest<WorkoutDTO>(method: .post, path: TrackingEndpoint.finishWorkout(id: id).path)
        return try await client.execute(requestModel)
    }

}

private struct CreateWorkoutRequestDTO: Encodable {
    let activityType: String
}
