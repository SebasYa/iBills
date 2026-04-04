//
//  HomeMonthSectionView.swift
//  iBills
//
//  Created by Sebastian Yanni on 03/04/2026.
//

import SwiftUI

struct HomeMonthSectionView: View {
    let monthSection: InvoiceMonthSection
    let isDeleteMode: Bool
    let isExpanded: Binding<Bool>
    let onDeleteMonth: () -> Void
    let onDeleteInvoice: (Invoice) -> Void

    var body: some View {
        Group {
            Button {
                withAnimation(.snappy) {
                    isExpanded.wrappedValue.toggle()
                }
            } label: {
                InvoiceMonthDisclosureRow(
                    title: monthSection.title,
                    invoiceCount: monthSection.invoices.count,
                    isDeleteMode: isDeleteMode,
                    isExpanded: isExpanded.wrappedValue
                )
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                if isDeleteMode {
                    Button(action: onDeleteMonth) {
                        Label("Eliminar mes", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 6, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            if isExpanded.wrappedValue {
                ForEach(monthSection.invoices) { invoice in
                    InvoiceRowView(
                        invoice: invoice,
                        disableSwipe: false,
                        onDelete: onDeleteInvoice
                    )
                    .listRowInsets(EdgeInsets(top: 4, leading: 10, bottom: 10, trailing: 10))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
        }
    }
}

private struct InvoiceMonthDisclosureRow: View {
    let title: String
    let invoiceCount: Int
    let isDeleteMode: Bool
    let isExpanded: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(title.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.75))

                    Circle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 4, height: 4)

                    Text("\(invoiceCount) factura\(invoiceCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.60))

                    Spacer()
                }

                if isDeleteMode {
                    Text("Deslizá para eliminar este mes")
                        .font(.caption2)
                        .foregroundStyle(.orange.opacity(0.9))
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.55))
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

#Preview {
    List {
        HomeMonthSectionView(
            monthSection: PreviewFixtures.monthSection(),
            isDeleteMode: false,
            isExpanded: .constant(true),
            onDeleteMonth: {},
            onDeleteInvoice: { _ in }
        )
    }
    .listStyle(.plain)
}
