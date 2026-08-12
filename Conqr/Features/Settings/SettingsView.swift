//
//  SettingsView.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI

struct SettingsView: View {
    var onLogout: () -> Void = {}

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
        return "\(version) (\(build))"
    }

    var body: some View {
        List {
            Section("Legal") {
                Link(destination: URL(string: "https://conqr.app/terms")!) {
                    HStack {
                        Text("Términos de uso")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(.primary)

                Link(destination: URL(string: "https://conqr.app/privacy")!) {
                    HStack {
                        Text("Política de privacidad")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(.primary)
            }

            Section {
                HStack {
                    Text("Versión")
                    Spacer()
                    Text(appVersion)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button(role: .destructive) {
                    onLogout()
                } label: {
                    HStack {
                        Spacer()
                        Text("Cerrar sesión")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Ajustes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
