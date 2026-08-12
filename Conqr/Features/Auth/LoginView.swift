//
//  LoginView.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI

struct LoginView: View {
    @AppStorage(AppSettingsKeys.loggedIn) private var isLoggedIn = false
    @State private var email = ""
    @State private var password = ""

    private var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty
    }

    var body: some View {
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

            PrimaryButton(title: "Iniciar sesión", fullWidth: true) {
                isLoggedIn = true
            }
            .disabled(!canSubmit)
            .opacity(canSubmit ? 1 : 0.5)

            Spacer()
            Spacer()
        }
        .padding(24)
    }
}

#Preview {
    LoginView()
}
