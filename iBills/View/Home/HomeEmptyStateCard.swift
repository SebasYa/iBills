//
//  HomeEmptyStateCard.swift
//  iBills
//
//  Created by Sebastian Yanni on 03/04/2026.
//

import SwiftUI

struct HomeEmptyStateCard: View {
    let isSearching: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: isSearching ? "magnifyingglass" : "doc.text.magnifyingglass")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))

            Text(isSearching ? "No encontramos facturas" : "Todavía no hay facturas")
                .font(.headline)
                .foregroundStyle(.white)

            Text(
                isSearching
                ? "Probá con otra razón social o número de factura."
                : "Agregá tu primera factura para empezar a ver el historial ordenado por año y mes."
            )
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .foregroundStyle(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.black.opacity(0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ZStack {
        Color.brown.opacity(0.25)
            .ignoresSafeArea()
        HomeEmptyStateCard(isSearching: false)
            .padding()
    }
}
