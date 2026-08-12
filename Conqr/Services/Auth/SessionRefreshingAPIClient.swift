//
//  SessionRefreshingAPIClient.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation


@MainActor
final class SessionRefreshingAPIClient: APIClientProtocol {
    private let inner: APIClientProtocol
    private let tokenStore: AuthTokenStoring
    private let onSessionExpired: () -> Void
    private var refreshTask: Task<Void, Error>?

    init(inner: APIClientProtocol, tokenStore: AuthTokenStoring, onSessionExpired: @escaping () -> Void) {
        self.inner = inner
        self.tokenStore = tokenStore
        self.onSessionExpired = onSessionExpired
    }

    func execute<Response: Decodable>(_ requestModel: APIRequest<Response>) async throws -> Response {
        do {
            return try await inner.execute(requestModel)
        } catch NetworkError.unauthorized where requestModel.requiresAuth {
            try await refreshSession()
            return try await inner.execute(requestModel)
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
            let requestModel = try APIRequest<AuthResponseDTO>(
                method: .post,
                route: .auth(.refresh),
                requiresAuth: false,
                body: RefreshPayload(refreshToken: refreshToken)
            )
            let response = try await inner.execute(requestModel)
            tokenStore.save(accessToken: response.accessToken, refreshToken: response.refreshToken)
        } catch {
            onSessionExpired()
            throw NetworkError.unauthorized
        }
    }
}
