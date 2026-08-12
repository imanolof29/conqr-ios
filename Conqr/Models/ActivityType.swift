//
//  ActivityType.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

enum ActivityType: CaseIterable, Identifiable, Equatable {
    case walk
    case run
    case cycle

    var id: Self { self }

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
}
