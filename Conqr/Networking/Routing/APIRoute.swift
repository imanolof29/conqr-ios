//
//  APIRoute.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

enum APIRoute {
    case auth(AuthEndpoint)

    var path: String {
        switch self {
        case .auth(let endpoint):
            return endpoint.path
        }
    }
}
