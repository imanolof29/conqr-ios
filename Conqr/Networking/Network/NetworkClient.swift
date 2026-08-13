//
//  NetworkClient.swift
//  Conqr
//
//  Created by Imanol Ortiz on 13/08/2026.
//

import Foundation

protocol NetworkClientProtocol {
    func execute<E: Endpoint>(_ endpoint: E) async throws -> E.Response
}

final class NetworkClient: NetworkClientProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder = .conqrDefault

    init(session: URLSession = URLSessionFactory.makeSession()) {
        self.session = session
    }

    func execute<E: Endpoint>(_ endpoint: E) async throws -> E.Response {
        try await execute(endpoint, allowRefresh: true)
    }

    private func execute<E: Endpoint>(_ endpoint: E, allowRefresh: Bool) async throws -> E.Response {
        let request = try makeRequest(endpoint)
        do {
            let (data, response) = try await session.data(for: request)
            try validate(response)
            return try decoder.decode(E.Response.self, from: data)
        } catch NetworkError.statusCode(401) where allowRefresh && endpoint.requiresAuth {
            try await refreshTokens()
            return try await execute(endpoint, allowRefresh: false)
        }
    }

    private func makeRequest<E: Endpoint>(_ endpoint: E) throws -> URLRequest {
        var comp = URLComponents(string: APIConfig.baseUrl + endpoint.path)
        comp?.queryItems = endpoint.queryItems

        guard let url = comp?.url else {
            throw NetworkError.badUrl
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        if let body = endpoint.body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if endpoint.requiresAuth, let token = TokenStorage.shared.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    private func refreshTokens() async throws {
        guard let refresh = TokenStorage.shared.refreshToken() else {
            TokenStorage.shared.clear()
            throw NetworkError.statusCode(401)
        }

        let request = makeRefreshRequest(refresh)
        do {
            let (data, response) = try await session.data(for: request)
            try validate(response)
            let tokenResponse = try decoder.decode(AuthResponseDTO.self, from: data)
            TokenStorage.shared.save(accesss: tokenResponse.accessToken, refresh: tokenResponse.refreshToken)
        } catch {
            TokenStorage.shared.clear()
            throw error
        }
    }

    private func makeRefreshRequest(_ token: String) -> URLRequest {
        let url = URL(string: APIConfig.baseUrl + "/auth/refresh")!
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func validate(_ response: URLResponse?) throws {
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.statusCode(http.statusCode)
        }
    }

}

extension JSONDecoder {
    /// NestJS/TypeORM serialize Date fields with millisecond precision
    /// (e.g. "2026-08-13T10:00:00.123Z") — the plain ISO8601 formatter rejects those.
    static let conqrDefault: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            if let date = ISO8601DateFormatter.withFractionalSeconds.date(from: raw) {
                return date
            }
            if let date = ISO8601DateFormatter().date(from: raw) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected ISO8601 date string, got \(raw)"
            )
        }
        return decoder
    }()
}

private extension ISO8601DateFormatter {
    static let withFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
