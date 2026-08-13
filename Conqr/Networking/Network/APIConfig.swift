//
//  APIConfig.swift
//  Conqr
//
//  Created by Imanol Ortiz on 13/08/2026.
//

import Foundation

protocol Endpoint {
    associatedtype Response: Decodable
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var requiresAuth: Bool { get }
    var body: Data? { get }
}

extension Endpoint {
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }
}

enum APIConfig {
    static let baseUrl: String = {
        #if DEBUG
        return "http://192.168.1.33:3000"
        #else
        return "https://api.conqr.app"
        #endif
    }()
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum URLSessionFactory {
    static func makeSession() -> URLSession {
        URLSession(configuration: .default)
    }
}
