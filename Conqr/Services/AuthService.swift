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
        let response: AuthResponseDTO = try await client.send(SignUpEndpoint(email: email, password: password))
        persistSession(response)
    }

    func signIn(email: String, password: String) async throws {
        let response: AuthResponseDTO = try await client.send(SignInEndpoint(email: email, password: password))
        persistSession(response)
    }

    /// Best-effort server-side sign-out (invalidates the refresh token). Local
    /// session is cleared regardless of whether the request succeeds.
    func signOut() async {
        try? await client.send(SignOutEndpoint())
        tokenStore.clear()
        UserDefaults.standard.set(false, forKey: AppSettingsKeys.loggedIn)
    }

    private func persistSession(_ response: AuthResponseDTO) {
        tokenStore.save(accessToken: response.accessToken, refreshToken: response.refreshToken)
        UserDefaults.standard.set(true, forKey: AppSettingsKeys.loggedIn)
    }
}

extension AuthService {
    /// Production instance, wired to `APIEnvironment.baseURL` and the Keychain.
    /// Access tokens refresh transparently on 401 via `SessionRefreshingNetworkClient`;
    /// the session only actually ends when the refresh token itself is rejected.
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
