//
//  APIClient.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

protocol APIClientProtocol {
    func execute<Response: Decodable>(_ requestModel: APIRequest<Response>) async throws -> Response
}

struct APIClient: APIClientProtocol {
    let baseURL: URL
    var session: URLSession = .shared
    var decoder: JSONDecoder = .conqrDefault
    var tokenProvider: @Sendable () -> String?

    func execute<Response: Decodable>(_ requestModel: APIRequest<Response>) async throws -> Response {
        var defaultHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]

        if requestModel.requiresAuth {
            guard let token = tokenProvider() else {
                throw NetworkError.unauthorized
            }
            defaultHeaders["Authorization"] = "Bearer \(token)"
        }

        let request = try requestModel.makeURLRequest(baseURL: baseURL, defaultHeaders: defaultHeaders)

        let (data, response) = try await perform(request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.transport("Response was not an HTTP response.")
        }
        switch httpResponse.statusCode {
        case 200..<300:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.server(statusCode: httpResponse.statusCode, message: friendlyMessage(from: data))
        }

        if Response.self == EmptyResponse.self {
            return EmptyResponse() as! Response
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(String(describing: error))
        }
    }

    private func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw NetworkError.transport(String(describing: error))
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

extension JSONDecoder {
    static let conqrDefault: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            if let date = ISO8601DateFormatter.withFractionalSeconds.date(from: raw) {
                return date
            }
            if let date = ISO8601DateFormatter.plain.date(from: raw) {
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
    // NestJS/TypeORM serialize Date fields with millisecond precision
    // (e.g. "2026-08-13T10:00:00.123Z") — the plain ISO8601 formatter rejects those.
    static let withFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let plain = ISO8601DateFormatter()
}
