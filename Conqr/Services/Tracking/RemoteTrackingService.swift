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

    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol) {
        self.client = client
    }

    func startWorkout(activityType: ActivityType) async throws -> WorkoutDTO {
        try await client.execute(StartWorkoutEndpoint(activityType: activityType))
    }

    func getWorkoutById(id: String) async throws -> WorkoutDTO {
        try await client.execute(GetWorkoutEndpoint(id: id))
    }

    func finishWorkout(id: String) async throws -> WorkoutDTO {
        try await client.execute(FinishWorkoutEndpoint(id: id))
    }
}

private struct CreateWorkoutRequestDTO: Encodable {
    let activityType: String
}

private struct StartWorkoutEndpoint: Endpoint {
    typealias Response = WorkoutDTO

    let activityType: ActivityType

    var path: String { TrackingEndpoint.workouts.path }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { true }

    var body: Data? {
        try? JSONEncoder().encode(CreateWorkoutRequestDTO(activityType: activityType.remoteValue))
    }
}

private struct GetWorkoutEndpoint: Endpoint {
    typealias Response = WorkoutDTO

    let id: String

    var path: String { TrackingEndpoint.workout(id: id).path }
    var method: HTTPMethod { .get }
    var requiresAuth: Bool { true }
}

private struct FinishWorkoutEndpoint: Endpoint {
    typealias Response = WorkoutDTO

    let id: String

    var path: String { TrackingEndpoint.finishWorkout(id: id).path }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { true }
}
