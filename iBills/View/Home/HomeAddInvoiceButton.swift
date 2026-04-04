//
//  HomeAddInvoiceButton.swift
//  iBills
//
//  Created by Sebastian Yanni on 03/04/2026.
//

import SwiftUI

struct HomeAddInvoiceButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Agregar factura")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)

                    Text("Registrá un nuevo comprobante")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color.green.opacity(0.72))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.brown.opacity(0.25)
            .ignoresSafeArea()
        HomeAddInvoiceButton(action: {})
            .padding()
    }
}
