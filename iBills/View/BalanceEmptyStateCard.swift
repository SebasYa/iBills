//
//  BalanceEmptyStateCard.swift
//  iBills
//
//  Created by Sebastian Yanni on 04/04/2026.
//

import SwiftUI

struct BalanceEmptyStateCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))

            Text("Todavía no hay balance para mostrar")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Agregá facturas para ver el IVA crédito, débito y el balance neto por año.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.black.opacity(0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ZStack {
        Color.yellow.opacity(0.20)
            .ignoresSafeArea()
        BalanceEmptyStateCard()
            .padding()
    }
}
