//
//  RegisterView.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    private var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }

    private var isPasswordValid: Bool {
        password.count >= 8
    }

    private var isSubmitting: Bool {
        authManager.authState == .inProgress(.signUp)
    }

    private var errorMessage: String? {
        if case .failed(.signUp, let message) = authManager.authState {
            return message
        }
        return nil
    }

    private var canSubmit: Bool {
        isEmailValid && isPasswordValid && password == confirmPassword && !isSubmitting
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Text("Crear cuenta")
                    .font(.largeTitle.weight(.bold))
                Text("Regístrate para empezar a conquistar")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 16) {
                AppTextField(placeholder: "Email", text: $email, icon: "envelope", keyboardType: .emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                AppTextField(placeholder: "Contraseña", text: $password, icon: "lock", isSecure: true)

                AppTextField(placeholder: "Confirmar contraseña", text: $confirmPassword, icon: "lock", isSecure: true)

                if !password.isEmpty && !isPasswordValid {
                    Text("Mínimo 8 caracteres")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if !confirmPassword.isEmpty && password != confirmPassword {
                    Text("Las contraseñas no coinciden")
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            PrimaryButton(title: isSubmitting ? "Creando cuenta…" : "Crear cuenta", fullWidth: true) {
                submit()
            }
            .disabled(!canSubmit)
            .opacity(canSubmit ? 1 : 0.5)

            Button("¿Ya tienes cuenta? Inicia sesión") {
                dismiss()
            }
            .font(.footnote)

            Spacer()
            Spacer()
        }
        .padding(24)
        .disabled(isSubmitting)
        .onDisappear {
            authManager.resetAuthState()
        }
    }

    private func submit() {
        Task {
            await authManager.signUp(email: email, password: password)
        }
    }
}

#Preview {
    RegisterView()
        .environment(AuthManager(client: NetworkClient()))
}
