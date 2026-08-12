//
//  ActivityType.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

enum ActivityType: CaseIterable {
    case walk
    case run
    case cycle
    
    var description: String {
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
            "walk"
        case .run:
            "run"
        case .cycle:
            "bike"
        }
    }
    
}
