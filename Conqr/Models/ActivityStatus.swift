//
//  ActivityStatus.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI

enum ActivityStatus: String, Codable {
    case inProgress
    case paused
    case completed

    var title: String {
        switch self {
        case .inProgress:
            "En curso"
        case .paused:
            "Pausado"
        case .completed:
            "Completado"
        }
    }

    var color: Color {
        switch self {
        case .inProgress:
            .blue
        case .paused:
            .orange
        case .completed:
            .green
        }
    }
}
