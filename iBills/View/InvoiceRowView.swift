//
//  InvoiceRowView.swift
//  iBills
//
//  Created by Sebastian Yanni on 03/04/2026.
//

import SwiftUI

struct InvoiceRowView: View {
    @State private var showDeleteInvoiceAlert = false
    var invoice: Invoice
    var disableSwipe: Bool
    let onDelete: (Invoice) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Razón Social:")
                Text("\(invoice.razonSocial)")
                    .foregroundStyle(Color("RazonSocialColor"))
            }
            Text("Tipo de IVA: \(invoice.category.title)")
            if let numeroFactura = invoice.numeroFactura, !numeroFactura.isEmpty {
                Text("Número de Factura: \(numeroFactura)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text("IVA: $\(invoice.vatRate, specifier: "%.1f")%")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Monto Total: $\(invoice.amount, specifier: "%.2f")")
                .foregroundStyle(Color("GreenMontoColor"))
            Text("Monto Neto: $\(invoice.netAmount, specifier: "%.2f")")
                .foregroundStyle(Color("GreenMontoColor"))
            Text("IVA Discriminado: $\(invoice.iva, specifier: "%.2f")")
                .foregroundStyle(Color("FullRedColor"))
            Text("Fecha: \(invoice.date, style: .date)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .cornerRadius(10)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if !disableSwipe {
                Button(role: .destructive) {
                    showDeleteInvoiceAlert = true
                } label: {
                    Label("Eliminar\nFactura", systemImage: "trash")
                }
            }
        }
        .alert(isPresented: $showDeleteInvoiceAlert) {
            Alert(
                title: Text("Eliminar Factura"),
                message: Text("¿Está seguro de que desea eliminar esta factura?"),
                primaryButton: .destructive(Text("Eliminar")) {
                    onDelete(invoice)
                },
                secondaryButton: .cancel()
            )
        }
    }
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
