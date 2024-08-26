//
//  BalanceView.swift
//  iBills
//
//  Created by Sebastian Yanni on 24/08/2024.
//

import SwiftUI
import SwiftData

struct BalanceView: View {
    @Query private var invoices: [Invoice]
    @StateObject private var viewModel = BalanceViewModel()

    var groupedInvoices: [String: [Invoice]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return Dictionary(grouping: invoices) { invoice in
            dateFormatter.string(from: invoice.date)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                ForEach(groupedInvoices.keys.sorted(), id: \.self) { year in
                    Section(header: Text("Balance de IVA \(year)")) {
                        let yearInvoices = groupedInvoices[year] ?? []
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Total IVA Débito:")
                                Spacer()
                                Text("\(viewModel.totalDebitIVA(invoices: yearInvoices), specifier: "%.2f")")
                                    .foregroundColor(.green)
                            }

                            HStack {
                                Text("Total IVA Crédito:")
                                Spacer()
                                Text("\(viewModel.totalCreditIVA(invoices: yearInvoices), specifier: "%.2f")")
                                    .foregroundColor(.red)
                            }

                            HStack {
                                Text("Balance Neto de IVA:")
                                Spacer()
                                Text("\(viewModel.netIVA(invoices: yearInvoices), specifier: "%.2f")")
                                    .fontWeight(.bold)
                                    .foregroundColor(viewModel.netIVA(invoices: yearInvoices) >= 0 ? .green : .red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Balance de IVA por Año")
        }
    }
}

#Preview {
    let modelContainer = try! ModelContainer(for: Invoice.self)
    return BalanceView()
        .environment(\.modelContext, modelContainer.mainContext)
}
