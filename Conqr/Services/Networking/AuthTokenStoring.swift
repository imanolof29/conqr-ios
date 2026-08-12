//
//  AuthTokenStoring.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation
import Security

/// Persists the credential `NetworkClient` attaches to authenticated requests.
/// Abstracted so the client stays testable (inject an in-memory fake in tests).
protocol AuthTokenStoring: AnyObject {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    func save(accessToken: String, refreshToken: String)
    func clear()
}

/// Keychain-backed implementation. Tokens never touch UserDefaults.
final class KeychainTokenStore: AuthTokenStoring {
    private let service: String

    init(service: String = Bundle.main.bundleIdentifier ?? "com.imanolortiz.Conqr") {
        self.service = service
    }

    var accessToken: String? { read(account: Account.accessToken) }
    var refreshToken: String? { read(account: Account.refreshToken) }

    func save(accessToken: String, refreshToken: String) {
        write(accessToken, account: Account.accessToken)
        write(refreshToken, account: Account.refreshToken)
    }

    func clear() {
        SecItemDelete(query(account: Account.accessToken) as CFDictionary)
        SecItemDelete(query(account: Account.refreshToken) as CFDictionary)
    }

    // MARK: - Keychain plumbing

    private enum Account {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }

    private func read(account: String) -> String? {
        var searchQuery = query(account: account)
        searchQuery[kSecReturnData as String] = true
        searchQuery[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(searchQuery as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func write(_ value: String, account: String) {
        let data = Data(value.utf8)

        var addQuery = query(account: account)
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let attributes: [String: Any] = [kSecValueData as String: data]
            SecItemUpdate(query(account: account) as CFDictionary, attributes as CFDictionary)
        }
    }

    private func query(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
