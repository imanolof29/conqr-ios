//
//  ActivityType.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI

enum ActivityType: String, CaseIterable, Identifiable, Codable, Equatable {
    case walk
    case run
    case cycle

    var id: Self { self }

    /// Backend (nest/conqr) ActivityType enum values — distinct from the
    /// lowercase raw value used for local persistence.
    var remoteValue: String {
        switch self {
        case .walk: "WALKING"
        case .run: "RUNNING"
        case .cycle: "CYCLING"
        }
    }

    var title: String {
        switch self {
        case .walk:
            "Andar"
        case .run:
            "Correr"
        case .cycle:
            "Bici"
        }
    }

    var icon: String {
        switch self {
        case .walk:
            "figure.walk"
        case .run:
            "figure.run"
        case .cycle:
            "bicycle"
        }
    }

    var color: Color {
        switch self {
        case .walk:
            .green
        case .run:
            .orange
        case .cycle:
            .blue
        }
    }
}
