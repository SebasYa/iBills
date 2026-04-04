//
//  GraphOverviewCard.swift
//  iBills
//
//  Created by Sebastian Yanni on 04/04/2026.
//

import SwiftUI

struct GraphOverviewCard: View {
    let overview: GraphOverview
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Resumen del período")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)

                Text("\(overview.title) · \(overview.periodText)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
            }

            HStack(spacing: 12) {
                overviewMetric(
                    title: "Último acumulado",
                    value: InvoiceDisplayFormatter.currency(overview.latestValue),
                    tint: color
                )

                overviewMetric(
                    title: "Pico del período",
                    value: InvoiceDisplayFormatter.currency(overview.peakValue),
                    tint: .orange
                )
            }

            overviewMetric(
                title: "Días con movimientos",
                value: "\(overview.movementCount)",
                tint: .blue
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.14))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func overviewMetric(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.68))

            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(tint.opacity(0.16))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(tint.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ZStack {
        Color.green.opacity(0.20)
            .ignoresSafeArea()
        GraphOverviewCard(
            overview: GraphOverview(
                title: "IVA Crédito",
                periodText: "2 mar 2026 - 12 abr 2026",
                latestValue: Decimal(string: "315.00") ?? .zero,
                peakValue: Decimal(string: "420.00") ?? .zero,
                movementCount: 6
            ),
            color: .green
        )
        .padding()
    }
}
