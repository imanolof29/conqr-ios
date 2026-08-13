//
//  NetworkError.swift
//  Conqr
//
//  Created by Imanol Ortiz on 13/08/2026.
//

import Foundation

enum NetworkError: LocalizedError {
    case badUrl
    case invalidResponse
    case statusCode(Int)
    case decoding
    
    var errorDescription: String? {
        switch self {
        case .badUrl: "Invalid URL"
        case .invalidResponse: "Invalid response"
        case .statusCode(let code): "Invalid status code: \(code)"
        case .decoding: "Failed to decode response"
        }
    }
    
}
