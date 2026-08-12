//
//  AuthEndpoints.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

struct AuthResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}

enum AuthEndpoint: Endpoint {
    case signUp(email: String, password: String)
    case signIn(email: String, password: String)
    case refresh(refreshToken: String)
    case signOut

    var path: String {
        switch self {
        case .signUp: return "auth/sign-up"
        case .signIn: return "auth/sign-in"
        case .refresh: return "auth/refresh"
        case .signOut: return "auth/sign-out"
        }
    }

    var method: HTTPMethod { .post }

    var requiresAuth: Bool {
        switch self {
        case .signOut: return true
        case .signUp, .signIn, .refresh: return false
        }
    }

    var body: [String: Any]? {
        switch self {
        case .signUp(let email, let password), .signIn(let email, let password):
            return ["email": email, "password": password]
        case .refresh(let refreshToken):
            return ["refreshToken": refreshToken]
        case .signOut:
            return nil
        }
    }
}
