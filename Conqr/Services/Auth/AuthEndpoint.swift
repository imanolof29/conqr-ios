//
//  AuthEndpoint.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

enum AuthEndpoint {
    case signUp
    case signIn
    case refresh
    case signOut

    var path: String {
        switch self {
        case .signUp: return "auth/sign-up"
        case .signIn: return "auth/sign-in"
        case .refresh: return "auth/refresh"
        case .signOut: return "auth/sign-out"
        }
    }
}
