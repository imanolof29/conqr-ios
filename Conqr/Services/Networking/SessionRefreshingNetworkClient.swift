//
//  SessionRefreshingNetworkClient.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

/// Decorates a `NetworkClientProtocol`: on a 401 from an authenticated
/// endpoint, silently trades the refresh token for a new access/refresh
/// pair and retries the request once. This is what keeps a session alive
/// past the access token's 15-minute lifetime without re-prompting login.
///
/// Concurrent 401s share a single in-flight refresh instead of racing
/// each other. If the refresh itself fails — refresh token expired or
/// revoked — `onSessionExpired` runs and the failure propagates as-is.
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
            let response: AuthResponseDTO = try await inner.send(RefreshTokenEndpoint(refreshToken: refreshToken))
            tokenStore.save(accessToken: response.accessToken, refreshToken: response.refreshToken)
        } catch {
            onSessionExpired()
            throw NetworkError.unauthorized
        }
    }
}
