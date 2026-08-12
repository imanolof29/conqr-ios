//
//  PrimaryButtonStyle.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var shape: AnyShape = AnyShape(Capsule())
    var horizontalPadding: CGFloat = 24
    var verticalPadding: CGFloat = 12

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .contentShape(shape)
            .glassEffect(.regular.tint(.accentColor).interactive(), in: shape)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {

    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }

    static func primary(
        shape: some Shape,
        horizontalPadding: CGFloat = 24,
        verticalPadding: CGFloat = 12
    ) -> PrimaryButtonStyle {
        PrimaryButtonStyle(
            shape: AnyShape(shape),
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding
        )
    }
}
