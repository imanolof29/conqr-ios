//
//  NetworkClient.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

protocol NetworkClientProtocol {
    @discardableResult
    func send<E: Endpoint, Response: Decodable>(_ endpoint: E) async throws -> Response
}

extension NetworkClientProtocol {
    @discardableResult
    func send<E: Endpoint>(_ endpoint: E) async throws -> EmptyResponse {
        try await send(endpoint)
    }
}

final class NetworkClient: NetworkClientProtocol {
    private let baseURL: URL
    private let session: URLSession
    private let tokenStore: AuthTokenStoring
    private let decoder: JSONDecoder

    init(
        baseURL: URL,
        session: URLSession = .shared,
        tokenStore: AuthTokenStoring,
        decoder: JSONDecoder = .conqrDefault
    ) {
        self.baseURL = baseURL
        self.session = session
        self.tokenStore = tokenStore
        self.decoder = decoder
    }

    @discardableResult
    func send<E: Endpoint, Response: Decodable>(_ endpoint: E) async throws -> Response {
        let request = try buildRequest(for: endpoint)
        let (data, response) = try await execute(request)
        try validate(response, data: data)

        if Response.self == EmptyResponse.self {
            return EmptyResponse() as! Response
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(String(describing: error))
        }
    }

    // MARK: - Request building

    private func buildRequest<E: Endpoint>(for endpoint: E) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = endpoint.queryItems
        guard let url = components.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if endpoint.requiresAuth {
            guard let token = tokenStore.accessToken else {
                throw NetworkError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = endpoint.body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                throw NetworkError.encodingFailed(String(describing: error))
            }
        }

        return request
    }

    // MARK: - Execution

    private func execute(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw NetworkError.transport(String(describing: error))
        }
    }

    private func validate(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.transport("Response was not an HTTP response.")
        }

        switch httpResponse.statusCode {
        case 200..<300:
            return
        case 401:
            throw NetworkError.unauthorized
        default:
            let message = friendlyMessage(from: data) ?? String(data: data, encoding: .utf8)
            throw NetworkError.server(statusCode: httpResponse.statusCode, message: message)
        }
    }

    private func friendlyMessage(from data: Data) -> String? {
        guard let payload = try? decoder.decode(APIErrorPayload.self, from: data) else { return nil }
        return payload.message
    }
}

private struct APIErrorPayload: Decodable {
    let message: String

    private enum CodingKeys: String, CodingKey { case message }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let single = try? container.decode(String.self, forKey: .message) {
            message = single
        } else {
            let multiple = try container.decode([String].self, forKey: .message)
            message = multiple.joined(separator: "\n")
        }
    }
}

// MARK: - Codec defaults

extension JSONDecoder {
    static let conqrDefault: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
