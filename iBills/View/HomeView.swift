//
//  Home.swift
//  iBills
//
//  Created by Sebastian Yanni on 05/08/2024.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query private var invoices: [Invoice]
    
    @State private var showAddBill = false
    @State private var searchText = ""
    
    var filteredInvoices: [Invoice] {
        if searchText.isEmpty {
            return invoices
        } else {
            return invoices.filter { invoice in
                invoice.razonSocial.localizedCaseInsensitiveContains(searchText) ||
                (invoice.numeroFactura?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }

    var groupedInvoices: [String: [Invoice]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return Dictionary(grouping: invoices) { invoice in
            dateFormatter.string(from: invoice.date)
        }
    }

    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Buscar Facturas")) {
                        TextField("Buscar por Razón Social o Número de Factura", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Button("Agregar Factura") {
                        showAddBill.toggle()
                    }
                    
                    if searchText.isEmpty {
                        Section(header: Text("Facturas por Año")) {
                            
                            ForEach(groupedInvoices.keys.sorted(), id: \.self) { year in
                                DisclosureGroup(year) {
                                    ForEach(groupedInvoices[year] ?? []) { invoice in
                                        VStack(alignment: .leading) {
                                            Text("Razón Social: \(invoice.razonSocial)")
                                            if let numeroFactura = invoice.numeroFactura {
                                                Text("Número de Factura: \(numeroFactura)")
                                            }
                                            Text("IVA: \(invoice.vatRate, specifier: "%.1f")%")
                                            Text("Monto Total: \(invoice.amount, specifier: "%.2f")")
                                            Text("Monto Neto: \(invoice.netAmount, specifier: "%.2f")")
                                            Text("IVA Discriminado: \(invoice.iva, specifier: "%.2f")")
                                            Text("Fecha: \(invoice.date, style: .date)")
                                            Text("Es Débito: \(invoice.isDebit ? "Sí" : "No")")
                                        }
                                    }
                                    .onDelete { indexSet in
                                        for index in indexSet {
                                            if let invoiceToDelete = groupedInvoices[year]?[index] {
                                                context.delete(invoiceToDelete)
                                            }
                                        }
                                        do {
                                            try context.save()
                                        } catch {
                                            print("Error al guardar el contexto: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        // Muestra solo las facturas filtradas durante la búsqueda
                        Section(header: Text("Resultados de Búsqueda")) {
                            ForEach(filteredInvoices) { invoice in
                                VStack(alignment: .leading) {
                                    Text("Razón Social: \(invoice.razonSocial)")
                                    if let numeroFactura = invoice.numeroFactura {
                                        Text("Número de Factura: \(numeroFactura)")
                                    }
                                    Text("IVA: \(invoice.vatRate, specifier: "%.1f")%")
                                    Text("Monto Total: \(invoice.amount, specifier: "%.2f")")
                                    Text("Monto Neto: \(invoice.netAmount, specifier: "%.2f")")
                                    Text("IVA Discriminado: \(invoice.iva, specifier: "%.2f")")
                                    Text("Fecha: \(invoice.date, style: .date)")
                                    Text("Es Débito: \(invoice.isDebit ? "Sí" : "No")")
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Facturas")
            .sheet(isPresented: $showAddBill) {
                AddInvoiceView()
                    .environment(\.modelContext, context)
            }
        }
    }
}

#Preview {
    HomeView()
}
