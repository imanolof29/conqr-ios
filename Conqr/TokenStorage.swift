//
//  TokenStorage.swift
//  Conqr
//
//  Created by Imanol Ortiz on 13/08/2026.
//

import Foundation

final class TokenStorage {
    
    static let shared = TokenStorage()
    
    private init() {}
    
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"
    
    func accessToken() -> String? {
        get(key: accessTokenKey)
    }
    
    func refreshToken() -> String? {
        get(key: refreshTokenKey)
    }
    
    func save(accesss: String, refresh: String) {
        save(value: accesss, key: accessTokenKey)
        save(value: refresh, key: refreshTokenKey)
    }
    
    func clear() {
        delete(key: accessTokenKey)
        delete(key: refreshTokenKey)
    }

    /// Decoded from the access token's `sub` claim — the backend doesn't
    /// return the user id separately on sign-in/refresh.
    var currentUserId: String? {
        guard let token = accessToken() else { return nil }
        return Self.userId(fromJWT: token)
    }

    private static func userId(fromJWT token: String) -> String? {
        let segments = token.split(separator: ".")
        guard segments.count > 1 else { return nil }

        var base64 = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64 += "=" }

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json["sub"] as? String
    }
    
    private func save(value: String, key: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &item)
        guard let data = item as? Data else { return nil }
        return String(decoding: data, as: UTF8.self)
    }
    
    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
    
}
