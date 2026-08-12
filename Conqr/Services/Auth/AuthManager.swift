//
//  AuthManager.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation
import Observation

enum AuthOperation: Equatable {
    case signIn
    case signUp
    case signOut
}


@MainActor
@Observable
final class AuthManager {
    private(set) var isAuthenticated: Bool
    var authState: MutationState<AuthOperation> = .idle

    private let tokenStore: AuthTokenStoring
    private var service: AuthServiceProtocol

    init(tokenStore: AuthTokenStoring = KeychainTokenStore()) {
        self.tokenStore = tokenStore
        self.isAuthenticated = tokenStore.accessToken != nil

        let rawClient = APIClient(baseURL: APIEnvironment.baseURL, tokenProvider: { tokenStore.accessToken })
        self.service = AuthService(client: rawClient)

        let refreshingClient = SessionRefreshingAPIClient(
            inner: rawClient,
            tokenStore: tokenStore,
            onSessionExpired: { [weak self] in self?.handleSessionExpired() }
        )
        self.service = AuthService(client: refreshingClient)
    }

    init(service: AuthServiceProtocol, tokenStore: AuthTokenStoring) {
        self.service = service
        self.tokenStore = tokenStore
        self.isAuthenticated = tokenStore.accessToken != nil
    }

    func signUp(email: String, password: String) async {
        authState = .inProgress(.signUp)
        do {
            let response = try await service.signUp(email: email, password: password)
            persist(response)
            authState = .succeeded(.signUp)
        } catch {
            authState = .failed(.signUp, message(for: error))
        }
    }

    func signIn(email: String, password: String) async {
        authState = .inProgress(.signIn)
        do {
            let response = try await service.signIn(email: email, password: password)
            persist(response)
            authState = .succeeded(.signIn)
        } catch {
            authState = .failed(.signIn, message(for: error))
        }
    }

    func signOut() async {
        authState = .inProgress(.signOut)
        try? await service.signOut()
        tokenStore.clear()
        isAuthenticated = false
        authState = .succeeded(.signOut)
    }

    func resetAuthState() {
        authState = .idle
    }

    func handleSessionExpired() {
        tokenStore.clear()
        isAuthenticated = false
    }

    private func persist(_ response: AuthResponseDTO) {
        tokenStore.save(accessToken: response.accessToken, refreshToken: response.refreshToken)
        isAuthenticated = true
    }

    private func message(for error: Error) -> String {
        (error as? NetworkError)?.userMessage ?? error.localizedDescription
    }
}
