//
//  HomeYearSectionView.swift
//  iBills
//
//  Created by Sebastian Yanni on 03/04/2026.
//

import SwiftUI

struct HomeYearSectionView: View {
    let yearSection: InvoiceYearSection
    let isDeleteMode: Bool
    let isExpanded: Binding<Bool>
    let monthBinding: (InvoiceMonthSection) -> Binding<Bool>
    let onDeleteYear: () -> Void
    let onDeleteMonth: (InvoiceMonthSection) -> Void
    let onDeleteInvoice: (Invoice) -> Void

    var body: some View {
        Section {
            Button {
                withAnimation(.snappy) {
                    isExpanded.wrappedValue.toggle()
                }
            } label: {
                InvoiceYearDisclosureCard(
                    year: yearSection.year,
                    invoiceCount: yearSection.invoiceCount,
                    isDeleteMode: isDeleteMode,
                    isExpanded: isExpanded.wrappedValue
                )
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                if isDeleteMode {
                    Button(action: onDeleteYear) {
                        Label("Eliminar año", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 6, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            if isExpanded.wrappedValue {
                ForEach(yearSection.months) { monthSection in
                    HomeMonthSectionView(
                        monthSection: monthSection,
                        isDeleteMode: isDeleteMode,
                        isExpanded: monthBinding(monthSection),
                        onDeleteMonth: {
                            onDeleteMonth(monthSection)
                        },
                        onDeleteInvoice: onDeleteInvoice
                    )
                }
            }
        }
    }
}

private struct InvoiceYearDisclosureCard: View {
    let year: String
    let invoiceCount: Int
    let isDeleteMode: Bool
    let isExpanded: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(year)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("\(invoiceCount) factura\(invoiceCount == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))

                if isDeleteMode {
                    Label("Deslizá esta tarjeta para eliminar el año", systemImage: "trash.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.55))
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
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

#Preview {
    List {
        HomeYearSectionView(
            yearSection: PreviewFixtures.yearSection(),
            isDeleteMode: false,
            isExpanded: .constant(true),
            monthBinding: { _ in .constant(true) },
            onDeleteYear: {},
            onDeleteMonth: { _ in },
            onDeleteInvoice: { _ in }
        )
    }
    .listStyle(.plain)
}
