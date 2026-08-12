//
//  PrimaryButton.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var shape: AnyShape = AnyShape(Capsule())
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if let icon {
                Label(title, systemImage: icon)
            } else {
                Text(title)
            }
        }
        .buttonStyle(.primary(shape: shape))
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Iniciar") {}

        PrimaryButton(
            title: "Agregar",
            icon: "plus",
            shape: AnyShape(RoundedRectangle(cornerRadius: 14))
        ) {}
    }
    .padding()
    .background(.gray.opacity(0.2))
}
