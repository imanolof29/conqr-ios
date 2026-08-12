//
//  MutationState.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

enum MutationState<Operation: Equatable>: Equatable {
    case idle
    case inProgress(Operation)
    case succeeded(Operation)
    case failed(Operation, String)
}
