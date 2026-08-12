//
//  APIRoute.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

enum APIRoute {
    case auth(AuthEndpoint)
    case tracking(TrackingEndpoint)

    var path: String {
        switch self {
        case .auth(let endpoint):
            return endpoint.path
        case .tracking(let endpoint):
            return endpoint.path
        }
    }
}
