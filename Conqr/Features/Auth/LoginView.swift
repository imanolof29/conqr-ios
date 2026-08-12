//
//  LoginView.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager

    @State private var email = ""
    @State private var password = ""
    @State private var showsRegister = false

    private var isSubmitting: Bool {
        authManager.authState == .inProgress(.signIn)
    }

    private var errorMessage: String? {
        if case .failed(.signIn, let message) = authManager.authState {
            return message
        }
        return nil
    }

    private var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && !isSubmitting
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Bienvenido")
                        .font(.largeTitle.weight(.bold))
                    Text("Inicia sesión para continuar")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 16) {
                    AppTextField(placeholder: "Email", text: $email, icon: "envelope", keyboardType: .emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    AppTextField(placeholder: "Contraseña", text: $password, icon: "lock", isSecure: true)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                PrimaryButton(title: isSubmitting ? "Iniciando…" : "Iniciar sesión", fullWidth: true) {
                    submit()
                }
                .disabled(!canSubmit)
                .opacity(canSubmit ? 1 : 0.5)

                Button("¿No tienes cuenta? Regístrate") {
                    showsRegister = true
                }
                .font(.footnote)

                Spacer()
                Spacer()
            }
            .padding(24)
            .disabled(isSubmitting)
            .sheet(isPresented: $showsRegister) {
                RegisterView()
            }
        }
    }

    private func submit() {
        Task {
            await authManager.signIn(email: email, password: password)
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthManager(tokenStore: KeychainTokenStore()))
}
