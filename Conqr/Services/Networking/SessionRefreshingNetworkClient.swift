//
//  SessionRefreshingNetworkClient.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

@MainActor
final class SessionRefreshingNetworkClient: NetworkClientProtocol {
    private let inner: NetworkClientProtocol
    private let tokenStore: AuthTokenStoring
    private let onSessionExpired: () -> Void
    private var refreshTask: Task<Void, Error>?

    init(inner: NetworkClientProtocol, tokenStore: AuthTokenStoring, onSessionExpired: @escaping () -> Void) {
        self.inner = inner
        self.tokenStore = tokenStore
        self.onSessionExpired = onSessionExpired
    }

    func send<E: Endpoint, Response: Decodable>(_ endpoint: E) async throws -> Response {
        do {
            return try await inner.send(endpoint)
        } catch NetworkError.unauthorized where endpoint.requiresAuth {
            try await refreshSession()
            return try await inner.send(endpoint)
        }
    }

    private func refreshSession() async throws {
        if let refreshTask {
            return try await refreshTask.value
        }

        let task = Task { try await performRefresh() }
        refreshTask = task
        defer { refreshTask = nil }
        try await task.value
    }

    private func performRefresh() async throws {
        guard let refreshToken = tokenStore.refreshToken else {
            onSessionExpired()
            throw NetworkError.unauthorized
        }

        do {
            let response: AuthResponseDTO = try await inner.send(AuthEndpoint.refresh(refreshToken: refreshToken))
            tokenStore.save(accessToken: response.accessToken, refreshToken: response.refreshToken)
        } catch {
            onSessionExpired()
            throw NetworkError.unauthorized
        }
    }
}
