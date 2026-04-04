//
//  InvoiceRowView.swift
//  iBills
//
//  Created by Sebastian Yanni on 03/04/2026.
//

import SwiftUI

struct InvoiceRowView: View {
    let invoice: Invoice
    let disableSwipe: Bool
    let onDelete: (Invoice) -> Void

    private var accentColor: Color {
        invoice.category.isCredit ? .green : .red
    }

    private var categoryIcon: String {
        invoice.category.isCredit ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(invoice.razonSocial)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if let numeroFactura = invoice.numeroFactura, !numeroFactura.isEmpty {
                        Text("Factura \(numeroFactura)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Text(InvoiceDisplayFormatter.date(invoice.date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.leading, 10)

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(InvoiceDisplayFormatter.currency(invoice.amountDecimal))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)

                    Text("Total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 8) {
                InvoiceTagView(
                    title: invoice.category.balanceTitle,
                    systemImage: categoryIcon,
                    tint: accentColor
                )

                InvoiceTagView(
                    title: "\(InvoiceDisplayFormatter.vat(invoice.vatRate))% IVA",
                    systemImage: "percent",
                    tint: .blue
                )
            }
            .padding(.leading, 10)
            .padding(.top, 10)

            HStack(spacing: 12) {
                InvoiceMetricItemView(
                    title: "Neto",
                    value: InvoiceDisplayFormatter.currency(invoice.netAmountDecimal)
                )

                InvoiceMetricItemView(
                    title: "IVA",
                    value: InvoiceDisplayFormatter.currency(invoice.ivaDecimal)
                )
            }

        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
        )
        .overlay(alignment: .leading) {
            Capsule()
                .fill(accentColor.gradient)
                .frame(width: 6)
                .padding(.leading, 10)
                .padding(.vertical, 14)
        }
        .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 8)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if !disableSwipe {
                Button {
                    onDelete(invoice)
                } label: {
                    Label("Eliminar", systemImage: "trash")
                }
                .tint(.red)
            }
        }
    }
}

private struct InvoiceTagView: View {
    let title: String
    let systemImage: String
    let tint: Color

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(tint.opacity(0.16), in: Capsule())
            .foregroundStyle(tint)
    }
}

private struct InvoiceMetricItemView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }
}

enum InvoiceDisplayFormatter {
    static func currency(_ value: Decimal) -> String {
        currencyFormatter.string(from: NSDecimalNumber(decimal: value)) ?? "$0,00"
    }

    static func vat(_ value: Double) -> String {
        value.formatted(
            .number
                .locale(Locale(identifier: "es_AR"))
                .precision(.fractionLength(0...1))
        )
    }

    static func date(_ value: Date) -> String {
        dateFormatter.string(from: value)
    }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "es_AR")
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_AR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

#Preview {
    InvoiceRowView(
        invoice: Invoice(
            amount: 1210.00,
            vatRate: 21.0,
            isCredit: true,
            date: .now,
            razonSocial: "Acme S.A.",
            numeroFactura: "A-0001-00001234"
        ),
        disableSwipe: false,
        onDelete: { _ in }
    )
}
