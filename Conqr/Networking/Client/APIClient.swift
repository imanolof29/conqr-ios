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
    var tokenProvider: () -> String?

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

    private func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
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
            let message = friendlyMessage(from: data)
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

extension JSONDecoder {
    static let conqrDefault: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
