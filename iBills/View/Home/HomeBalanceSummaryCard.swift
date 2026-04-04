//
//  HomeBalanceSummaryCard.swift
//  iBills
//
//  Created by Sebastian Yanni on 03/04/2026.
//

import SwiftUI

struct HomeBalanceSummaryCard: View {
    let years: [String]
    @Binding var selectedYear: String
    let invoiceCount: Int
    let summary: VATBalanceSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Balance anual de IVA")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)

                Text("\(invoiceCount) factura\(invoiceCount == 1 ? "" : "s") en \(selectedYear)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(years, id: \.self) { year in
                        Button {
                            selectedYear = year
                        } label: {
                            Text(year)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selectedYear == year ? Color.white.opacity(0.24) : Color.white.opacity(0.08))
                                )
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            HStack(spacing: 12) {
                SummaryMetricCard(
                    title: "IVA Crédito",
                    value: InvoiceDisplayFormatter.currency(summary.totalCreditIVA),
                    tint: .green
                )

                SummaryMetricCard(
                    title: "IVA Débito",
                    value: InvoiceDisplayFormatter.currency(summary.totalDebitIVA),
                    tint: .red
                )
            }

            SummaryMetricCard(
                title: "Balance Neto",
                value: InvoiceDisplayFormatter.currency(summary.netIVA),
                tint: summary.netIVA >= 0 ? .blue : .orange
            )
        }
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
}

private struct SummaryMetricCard: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
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
        Color.yellow.opacity(0.20)
            .ignoresSafeArea()
        HomeBalanceSummaryCard(
            years: ["2026", "2025", "2024"],
            selectedYear: .constant("2026"),
            invoiceCount: 4,
            summary: PreviewFixtures.balanceSummary()
        )
        .padding()
    }
}
