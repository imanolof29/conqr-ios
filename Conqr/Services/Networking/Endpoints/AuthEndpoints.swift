//
//  AuthEndpoints.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

/// Matches `AuthResponseDto` on the backend (`accessToken` + `refreshToken`).
struct AuthResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}

/// POST /auth/sign-up — matches `SignUpDto` (email, password ≥ 8 chars).
struct SignUpEndpoint: Endpoint {
    struct Body: Encodable {
        let email: String
        let password: String
    }

    let body: Body?

    var path: String { "auth/sign-up" }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { false }

    init(email: String, password: String) {
        body = Body(email: email, password: password)
    }
}

/// POST /auth/sign-in — matches `SignInDto`.
struct SignInEndpoint: Endpoint {
    struct Body: Encodable {
        let email: String
        let password: String
    }

    let body: Body?

    var path: String { "auth/sign-in" }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { false }

    init(email: String, password: String) {
        body = Body(email: email, password: password)
    }
}

/// POST /auth/refresh — matches `RefreshTokenDto`. Trades a refresh token
/// for a fresh access/refresh pair; no `Authorization` header involved.
struct RefreshTokenEndpoint: Endpoint {
    struct Body: Encodable {
        let refreshToken: String
    }

    let body: Body?

    var path: String { "auth/refresh" }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { false }

    init(refreshToken: String) {
        body = Body(refreshToken: refreshToken)
    }
}

/// POST /auth/sign-out — matches the `JwtAuthGuard`-protected endpoint;
/// invalidates the refresh token server-side.
struct SignOutEndpoint: Endpoint {
    var path: String { "auth/sign-out" }
    var method: HTTPMethod { .post }
}
