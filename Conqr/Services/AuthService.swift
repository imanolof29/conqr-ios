//
//  AuthService.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Combine
import Foundation


@MainActor
final class AuthService: ObservableObject {
    private let client: NetworkClientProtocol
    private let tokenStore: AuthTokenStoring

    init(client: NetworkClientProtocol, tokenStore: AuthTokenStoring) {
        self.client = client
        self.tokenStore = tokenStore
    }

    func signUp(email: String, password: String) async throws {
        let response: AuthResponseDTO = try await client.send(AuthEndpoint.signUp(email: email, password: password))
        persistSession(response)
    }

    func signIn(email: String, password: String) async throws {
        let response: AuthResponseDTO = try await client.send(AuthEndpoint.signIn(email: email, password: password))
        persistSession(response)
    }

    func signOut() async {
        try? await client.send(AuthEndpoint.signOut)
        tokenStore.clear()
        UserDefaults.standard.set(false, forKey: AppSettingsKeys.loggedIn)
    }

    private func persistSession(_ response: AuthResponseDTO) {
        tokenStore.save(accessToken: response.accessToken, refreshToken: response.refreshToken)
        UserDefaults.standard.set(true, forKey: AppSettingsKeys.loggedIn)
    }
}

extension AuthService {
    static func live() -> AuthService {
        let tokenStore = KeychainTokenStore()
        let rawClient = NetworkClient(baseURL: APIEnvironment.baseURL, tokenStore: tokenStore)
        let client = SessionRefreshingNetworkClient(
            inner: rawClient,
            tokenStore: tokenStore,
            onSessionExpired: {
                tokenStore.clear()
                UserDefaults.standard.set(false, forKey: AppSettingsKeys.loggedIn)
            }
        )
        return AuthService(client: client, tokenStore: tokenStore)
    }
}
