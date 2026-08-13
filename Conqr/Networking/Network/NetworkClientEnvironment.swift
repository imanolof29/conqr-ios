//
//  NetworkClientEnvironment.swift
//  Conqr
//
//  Created by Imanol Ortiz on 13/08/2026.
//

import SwiftUI

private struct NetworkClientKey: EnvironmentKey {
    static let defaultValue: NetworkClientProtocol = NetworkClient()
}

extension EnvironmentValues {
    var networkClient: NetworkClientProtocol {
        get { self[NetworkClientKey.self] }
        set { self[NetworkClientKey.self] = newValue }
    }
}
