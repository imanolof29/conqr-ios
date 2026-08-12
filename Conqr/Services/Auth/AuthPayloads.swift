//
//  AuthPayloads.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
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

struct RefreshPayload: Encodable {
    let refreshToken: String
}
