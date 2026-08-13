//
//  LoginEndpoint.swift
//  Conqr
//
//  Created by Imanol Ortiz on 13/08/2026.
//

import Foundation

struct AuthResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}

struct CredentialsPayload: Encodable {
    let email: String
    let password: String
}

struct LoginEndpoint: Endpoint {
    typealias Response = AuthResponseDTO

    let email: String
    let password: String

    var path: String { "/auth/sign-in" }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { false }

    var body: Data? {
        try? JSONEncoder().encode(CredentialsPayload(email: email, password: password))
    }
}

struct RegisterEndpoint: Endpoint {
    typealias Response = AuthResponseDTO

    let email: String
    let password: String

    var path: String { "/auth/sign-up" }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { false }

    var body: Data? {
        try? JSONEncoder().encode(CredentialsPayload(email: email, password: password))
    }
}
