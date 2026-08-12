//
//  Endpoint.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

/// Describes a single API request: where it goes, how it's made,
/// and what (if anything) it sends as a body.
///
/// Conforming types are typically lightweight enums or structs, e.g.:
///
/// ```swift
/// struct LoginEndpoint: Endpoint {
///     let email: String
///     let password: String
///
///     var path: String { "auth/login" }
///     var method: HTTPMethod { .post }
///     var requiresAuth: Bool { false }
///     var body: LoginRequestDTO? { LoginRequestDTO(email: email, password: password) }
/// }
/// ```
protocol Endpoint {
    /// Type of the JSON-encodable payload sent with this request.
    /// Defaults to `EmptyBody` for requests without one (GET, DELETE, etc.).
    associatedtype Body: Encodable = EmptyBody

    /// Path relative to the client's `baseURL`, without a leading slash (e.g. "users/me").
    var path: String { get }
    var method: HTTPMethod { get }
    /// Extra headers merged on top of the client's defaults. `nil` by default.
    var headers: [String: String]? { get }
    /// Query string parameters. `nil` by default.
    var queryItems: [URLQueryItem]? { get }
    /// Request payload, encoded as JSON. `nil` by default.
    var body: Body? { get }
    /// Whether the client should attach an `Authorization` header. `true` by default.
    var requiresAuth: Bool { get }
}

extension Endpoint {
    var headers: [String: String]? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var requiresAuth: Bool { true }
}

extension Endpoint where Body == EmptyBody {
    var body: EmptyBody? { nil }
}

/// Placeholder payload for endpoints that don't send a body.
struct EmptyBody: Encodable {}

/// Placeholder response for requests whose result the caller doesn't need.
struct EmptyResponse: Decodable {}
