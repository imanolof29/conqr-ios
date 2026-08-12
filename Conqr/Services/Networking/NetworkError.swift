//
//  NetworkError.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case encodingFailed(String)
    case decodingFailed(String)
    case unauthorized
    case server(statusCode: Int, message: String?)
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .encodingFailed(let reason):
            return "Failed to encode the request body: \(reason)"
        case .decodingFailed(let reason):
            return "Failed to decode the response: \(reason)"
        case .unauthorized:
            return "Session expired or unauthorized. Please sign in again."
        case .server(let statusCode, let message):
            return message ?? "Server returned status code \(statusCode)."
        case .transport(let reason):
            return "Network request failed: \(reason)"
        }
    }
}
