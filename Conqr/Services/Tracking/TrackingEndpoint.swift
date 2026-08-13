//
//  TrackingEndpoint.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

enum TrackingEndpoint {
    case workouts
    case workout(id: String)
    case finishWorkout(id: String)

    var path: String {
        switch self {
        case .workouts: return "workouts"
        case .workout(id: let id):
            return "workouts/\(id)"
        case .finishWorkout(id: let id):
            return "workouts/\(id)/finish"
        }
    }
}
