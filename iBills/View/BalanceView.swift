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

    var groupedInvoices: [String: [Invoice]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return Dictionary(grouping: invoices) { invoice in
            dateFormatter.string(from: invoice.date)
        }
    }

    var body: some View {
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
                    YearButtonsView(years: Array(groupedInvoices.keys.sorted()), selectedYear: $selectedYear)
                    
                    if let yearInvoices = groupedInvoices[selectedYear], !yearInvoices.isEmpty  {
                        Form {
                            Section(header: Text("Balance de IVA \(selectedYear)")) {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Text("Total IVA Crédito:")
                                            .foregroundStyle(Color("LDBrownColor"))
                                        Spacer()
                                        Text("$\(viewModel.totalCreditIVA(invoices: yearInvoices), specifier: "%.2f")")
                                            .foregroundColor(.green)
                                    }
                                    
                                    HStack {
                                        Text("Total IVA Débito:")
                                            .foregroundStyle(Color("LDBrownColor"))
                                        Spacer()
                                        Text("$\(viewModel.totalDebitIVA(invoices: yearInvoices), specifier: "%.2f")")
                                            .foregroundColor(.red)
                                    }

                                    HStack {
                                        Text("Balance Neto de IVA:")
                                            .foregroundStyle(Color("LDBrownColor"))
                                        Spacer()
                                        Text("$\(viewModel.netIVA(invoices: yearInvoices), specifier: "%.2f")")
                                            .fontWeight(.bold)
                                            .foregroundColor(viewModel.netIVA(invoices: yearInvoices) >= 0 ? .green : .red)
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
            // Obtener el año corriente
            let currentYear = Calendar.current.component(.year, from: Date())
            // Convertir el año a string
            let currentYearString = String(currentYear)
            // Establecer el año seleccionado al corriente si existe en los datos
            if groupedInvoices.keys.contains(currentYearString) {
                selectedYear = currentYearString
            } else {
                // Si el año actual no está disponible, seleccionar el primer año disponible
                selectedYear = groupedInvoices.keys.sorted().first ?? ""
            }
        }
    }
}

#Preview {
    BalanceView()
}
