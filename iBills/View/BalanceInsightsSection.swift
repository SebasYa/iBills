//
//  BalanceInsightsSection.swift
//  iBills
//
//  Created by Sebastian Yanni on 04/04/2026.
//

import SwiftUI

struct BalanceInsightsSection: View {
    let insights: BalanceInsights

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 16) {
            BalanceStatusCard(insights: insights)

            LazyVGrid(columns: columns, spacing: 12) {
                BalanceMetricCard(
                    title: "Comprobantes",
                    value: "\(insights.invoiceCount)",
                    tint: .blue
                )

                BalanceMetricCard(
                    title: "Compras",
                    value: "\(insights.creditInvoiceCount)",
                    tint: .green
                )

                BalanceMetricCard(
                    title: "Ventas",
                    value: "\(insights.debitInvoiceCount)",
                    tint: .red
                )

                BalanceMetricCard(
                    title: "IVA promedio",
                    value: InvoiceDisplayFormatter.currency(insights.averageIVA),
                    tint: .orange
                )
            }

            BalanceTaxableBaseCard(insights: insights)
        }
    }
}

private struct BalanceStatusCard: View {
    let insights: BalanceInsights

    var body: some View {
        let tone = insights.status.presentation

        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Label(tone.title, systemImage: tone.icon)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)

                Spacer()

                Text(InvoiceDisplayFormatter.currency(insights.absoluteNetIVA))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
            }

            Text(tone.message)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.78))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(tone.tint.opacity(0.22))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(tone.tint.opacity(0.28), lineWidth: 1)
                )
        )
    }
}

private struct BalanceMetricCard: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.68))

            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(tint.opacity(0.16))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(tint.opacity(0.24), lineWidth: 1)
                )
        )
    }
}

private struct BalanceTaxableBaseCard: View {
    let insights: BalanceInsights

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Base imponible neta")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            HStack(spacing: 12) {
                baseColumn(
                    title: "Compras",
                    value: InvoiceDisplayFormatter.currency(insights.creditNetAmount),
                    tint: .green
                )

                baseColumn(
                    title: "Ventas",
                    value: InvoiceDisplayFormatter.currency(insights.debitNetAmount),
                    tint: .red
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.black.opacity(0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func baseColumn(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.68))

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(tint.opacity(0.14))
        )
    }
}

private extension BalanceStatus {
    var presentation: (title: String, message: String, icon: String, tint: Color) {
        switch self {
        case .favorable:
            return (
                title: "Saldo técnico a favor",
                message: "El IVA crédito supera al débito en el año seleccionado.",
                icon: "arrow.down.circle.fill",
                tint: .green
            )
        case .payable:
            return (
                title: "IVA a pagar",
                message: "El IVA débito supera al crédito en el año seleccionado.",
                icon: "arrow.up.circle.fill",
                tint: .red
            )
        case .neutral:
            return (
                title: "Balance equilibrado",
                message: "El IVA crédito y el débito quedaron compensados.",
                icon: "equal.circle.fill",
                tint: .blue
            )
        }
    }
}

#Preview {
    ZStack {
        Color.yellow.opacity(0.20)
            .ignoresSafeArea()

        ScrollView {
            BalanceInsightsSection(insights: PreviewFixtures.balanceInsights())
                .padding()
        }
    }
}
