//
//  TrackingEndpoint.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

enum TrackingEndpoint {
    case workouts

    var path: String {
        switch self {
        case .workouts: return "tracking/workouts"
        }
    }
}
