//
//  BalanceView.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI
import SwiftData

struct BalanceView: View {
    @Query private var invoices: [Invoice]
    @StateObject private var viewModel = BalanceViewModel()

    @State private var selectedYear: String = ""

    var body: some View {
        let groupedInvoices = viewModel.groupedInvoices(byYearFrom: invoices)
        let availableYears = viewModel.availableYears(from: invoices)
        let selectedYearInvoices = groupedInvoices[selectedYear] ?? []
        let summary = viewModel.summary(for: selectedYearInvoices)

        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.yellow.opacity(0.6), Color.brown.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    // Year selection buttons
                    YearButtonsView(years: availableYears, selectedYear: $selectedYear)
                    
                    if !selectedYearInvoices.isEmpty  {
                        Form {
                            Section(header: Text("Balance de IVA \(selectedYear)")) {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Text("Total IVA Crédito:")
                                            .foregroundStyle(Color("LDBrownColor"))
                                        Spacer()
                                        Text("$\(summary.totalCreditIVADouble, specifier: "%.2f")")
                                            .foregroundColor(.green)
                                    }
                                    
                                    HStack {
                                        Text("Total IVA Débito:")
                                            .foregroundStyle(Color("LDBrownColor"))
                                        Spacer()
                                        Text("$\(summary.totalDebitIVADouble, specifier: "%.2f")")
                                            .foregroundColor(.red)
                                    }

                                    HStack {
                                        Text("Balance Neto de IVA:")
                                            .foregroundStyle(Color("LDBrownColor"))
                                        Spacer()
                                        Text("$\(summary.netIVADouble, specifier: "%.2f")")
                                            .fontWeight(.bold)
                                            .foregroundColor(summary.netIVADouble >= 0 ? .green : .red)
                                    }
                                }
                            }
                            .listRowBackground(Color.gray.opacity(0.3))
                        }
                        .foregroundStyle(Color("BWColor"))
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    } else {
                        Text("Ingresa Facturas para generar un Balance")
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                }
                .navigationTitle("Balance de IVA")
                .safeAreaPadding(.bottom, 5)
            }
        }
        .onAppear {
            selectedYear = viewModel.defaultSelectedYear(from: invoices, preferredYear: selectedYear)
        }
        .onChange(of: invoices.count) { _, _ in
            selectedYear = viewModel.defaultSelectedYear(from: invoices, preferredYear: selectedYear)
        }
    }
}

#Preview {
    BalanceView()
}
