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

    var path: String {
        switch self {
        case .workouts: return "tracking/workouts"
        case .workout(id: let id):
            return "tracking/workouts/\(id)"
        }
    }
}
