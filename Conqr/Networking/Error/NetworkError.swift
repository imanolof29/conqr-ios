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

    var userMessage: String {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .encodingFailed:
            return "Something went wrong preparing the request."
        case .decodingFailed:
            return "We received data in an unexpected format."
        case .unauthorized:
            return "Session expired or unauthorized. Please sign in again."
        case .server(let statusCode, let message):
            if let message { return message }
            switch statusCode {
            case 403: return "You do not have permission to perform this action."
            case 404: return "The requested resource could not be found."
            case 409: return "This action conflicts with existing data."
            case 429: return "Too many requests. Please wait a moment and try again."
            case 500...599: return "The server is having trouble right now. Please try again later."
            default: return "Something went wrong. Please try again."
            }
        case .transport(let reason):
            if reason.contains("notConnectedToInternet") {
                return "No internet connection. Check your network and try again."
            }
            if reason.contains("timedOut") {
                return "The request timed out. Please try again."
            }
            return "A network error occurred. Please try again."
        }
    }

    /// Verbose, developer-facing message.
    var debugMessage: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .encodingFailed(let reason):
            return "Encoding failed: \(reason)"
        case .decodingFailed(let reason):
            return "Decoding failed: \(reason)"
        case .unauthorized:
            return "Unauthorized (401)"
        case .server(let statusCode, let message):
            return "HTTP \(statusCode)\(message.map { ": \($0)" } ?? "")"
        case .transport(let reason):
            return "Transport error: \(reason)"
        }
    }

    var errorDescription: String? { userMessage }
}
