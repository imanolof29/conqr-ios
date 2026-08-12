//
//  APIEnvironment.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

enum APIEnvironment {
    static let baseURL: URL = {
        #if DEBUG
        return URL(string: "http://192.168.1.33:3000")!
        #else
        return URL(string: "https://api.conqr.app")!
        #endif
    }()
}
