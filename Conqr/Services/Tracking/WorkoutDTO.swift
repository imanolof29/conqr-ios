//
//  WorkoutDTO.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI

struct WorkoutDTO: Decodable, Identifiable, Equatable {
    let id: String
    let status: RemoteWorkoutStatus
    let distanceMeters: Double
    let polyline: String?
    let startedAt: Date
    let endedAt: Date?
}

enum RemoteWorkoutStatus: String, Decodable, Equatable {
    case active
    case finished

    var title: String {
        switch self {
        case .active: "En curso"
        case .finished: "Completado"
        }
    }

    var color: Color {
        switch self {
        case .active: .blue
        case .finished: .green
        }
    }
}

extension WorkoutDTO {
    var formattedDistance: String {
        distanceMeters.formattedAsDistance
    }

    var formattedDuration: String {
        (endedAt ?? Date()).timeIntervalSince(startedAt).formattedAsDuration
    }
}
