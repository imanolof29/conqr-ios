//
//  AuthService.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

protocol AuthServiceProtocol {
    func signUp(email: String, password: String) async throws -> AuthResponseDTO
    func signIn(email: String, password: String) async throws -> AuthResponseDTO
    func refresh(refreshToken: String) async throws -> AuthResponseDTO
    func signOut() async throws
}

struct AuthService: AuthServiceProtocol {
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func signUp(email: String, password: String) async throws -> AuthResponseDTO {
        let requestModel = try APIRequest<AuthResponseDTO>(
            method: .post,
            path: AuthEndpoint.signUp.path,
            requiresAuth: false,
            body: CredentialsPayload(email: email, password: password)
        )
        return try await client.execute(requestModel)
    }

    func signIn(email: String, password: String) async throws -> AuthResponseDTO {
        let requestModel = try APIRequest<AuthResponseDTO>(
            method: .post,
            path: AuthEndpoint.signIn.path,
            requiresAuth: false,
            body: CredentialsPayload(email: email, password: password)
        )
        return try await client.execute(requestModel)
    }

    func refresh(refreshToken: String) async throws -> AuthResponseDTO {
        let requestModel = try APIRequest<AuthResponseDTO>(
            method: .post,
            path: AuthEndpoint.refresh.path,
            requiresAuth: false,
            body: RefreshPayload(refreshToken: refreshToken)
        )
        return try await client.execute(requestModel)
    }

    func signOut() async throws {
        let requestModel = APIRequest<EmptyResponse>(method: .post, path: AuthEndpoint.signOut.path)
        _ = try await client.execute(requestModel)
    }
}
