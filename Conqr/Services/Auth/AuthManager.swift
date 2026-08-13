//
//  AuthManager.swift
//  Conqr
//
//  Created by Imanol Ortiz on 13/08/2026.
//

import Foundation
import Observation

enum AuthOperation: Equatable {
    case signIn
    case signUp
    case signOut
}

@MainActor
@Observable
final class AuthManager {
    private(set) var isAuthenticated: Bool
    var authState: MutationState<AuthOperation> = .idle

    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol) {
        self.client = client
        self.isAuthenticated = TokenStorage.shared.accessToken() != nil
    }

    func signIn(email: String, password: String) async {
        authState = .inProgress(.signIn)
        do {
            let response = try await client.execute(LoginEndpoint(email: email, password: password))
            persist(response)
            authState = .succeeded(.signIn)
        } catch {
            authState = .failed(.signIn, message(for: error))
        }
    }

    func signUp(email: String, password: String) async {
        authState = .inProgress(.signUp)
        do {
            let response = try await client.execute(RegisterEndpoint(email: email, password: password))
            persist(response)
            authState = .succeeded(.signUp)
        } catch {
            authState = .failed(.signUp, message(for: error))
        }
    }

    func signOut() async {
        authState = .inProgress(.signOut)
        TokenStorage.shared.clear()
        isAuthenticated = false
        authState = .succeeded(.signOut)
    }

    func resetAuthState() {
        authState = .idle
    }

    private func persist(_ response: AuthResponseDTO) {
        TokenStorage.shared.save(accesss: response.accessToken, refresh: response.refreshToken)
        isAuthenticated = true
    }

    private func message(for error: Error) -> String {
        (error as? NetworkError)?.errorDescription ?? error.localizedDescription
    }
}
