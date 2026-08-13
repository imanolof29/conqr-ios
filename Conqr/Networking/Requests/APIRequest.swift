//
//  APIRequest.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

struct EmptyResponse: Decodable {}

struct APIRequest<Response: Decodable> {
    let method: HTTPMethod
    let path: String
    var queryItems: [URLQueryItem]
    var headers: [String: String]
    var body: Data?
    var requiresAuth: Bool

    init(
        method: HTTPMethod,
        path: String,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        requiresAuth: Bool = true,
        body: Data? = nil
    ) {
        self.method = method
        self.path = path
        self.queryItems = queryItems
        self.headers = headers
        self.requiresAuth = requiresAuth
        self.body = body
    }

    init<Body: Encodable>(
        method: HTTPMethod,
        path: String,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        requiresAuth: Bool = true,
        encoder: JSONEncoder = JSONEncoder(),
        body: Body
    ) throws {
        do {
            self.body = try encoder.encode(body)
        } catch {
            throw NetworkError.encodingFailed(String(describing: error))
        }
        self.method = method
        self.path = path
        self.queryItems = queryItems
        self.headers = headers
        self.requiresAuth = requiresAuth
    }

    func makeURLRequest(baseURL: URL, defaultHeaders: [String: String] = [:]) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        var mergedHeaders = defaultHeaders
        mergedHeaders.merge(headers) { _, new in new }
        request.allHTTPHeaderFields = mergedHeaders

        request.httpBody = body

        return request
    }
}
