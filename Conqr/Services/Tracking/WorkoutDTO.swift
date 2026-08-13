//
//  WorkoutDTO.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

/// Mirrors backend WorkoutResponseDto (nest/conqr). No distance/polyline here —
/// the server no longer computes or stores those; local ActivityRecord is the
/// source of truth for route + distance display.
struct WorkoutDTO: Decodable, Identifiable, Equatable {
    let id: String
    let status: RemoteWorkoutStatus
    let activityType: RemoteActivityType
    let startedAt: Date
    let finishedAt: Date?
    let lastSequence: Int
    let lastH3: String?
}

enum RemoteWorkoutStatus: String, Decodable, Equatable {
    case active = "ACTIVE"
    case finished = "FINISHED"
}

enum RemoteActivityType: String, Decodable, Equatable {
    case running = "RUNNING"
    case walking = "WALKING"
    case cycling = "CYCLING"
}
