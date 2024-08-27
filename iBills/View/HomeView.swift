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
    
    // State variables to manage showing the add bill view and search text
    @State private var showAddBill = false
    @State private var searchText = ""
    
    // Computed property to filter invoices based on the search text
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

    // Computed property to group invoices by year
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
                    gradient: Gradient(colors: [Color.brown, Color.brown.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                VStack {
                    Button(action: {
                        showAddBill.toggle()
                    }) {
                        Label("Agregar Factura", systemImage: "plus.circle")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: 350)
                            .background(Color.green.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    Form {
                        
                        Section(header: HStack {
                            Spacer()
                            Text("Buscar Facturas")
                            Spacer()
                        }) {
                            TextField("Razón Social o Número de Factura", text: $searchText)
                                .foregroundStyle(Color.white)
                                .padding(8)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .listRowBackground(Color.clear)
                        
                        
                        
                        
                        
                        if searchText.isEmpty {
                            Section(header: HStack {
                                Spacer()
                                Text("Facturas por Año")
                                Spacer()
                            }) {
                                
                                ForEach(groupedInvoices.keys.sorted(), id: \.self) { year in
                                    DisclosureGroup(year) {
                                        ForEach(groupedInvoices[year] ?? []) { invoice in
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Razón Social: \(invoice.razonSocial)")
                                                Text("Es Débito: \(invoice.isDebit ? "Sí" : "No")")
                                                if let numeroFactura = invoice.numeroFactura {
                                                    Text("Número de Factura: \(numeroFactura)")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.secondary)
                                                }
                                                Text("IVA: $\(invoice.vatRate, specifier: "%.1f")%")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                                Text("Monto Total: $\(invoice.amount, specifier: "%.2f")")
                                                    .foregroundStyle(.green)
                                                Text("Monto Neto: $\(invoice.netAmount, specifier: "%.2f")")
                                                    .foregroundStyle(.green)
                                                Text("IVA Discriminado: $\(invoice.iva, specifier: "%.2f")")
                                                    .foregroundStyle(Color("FullRedColor"))
                                                Text("Fecha: \(invoice.date, style: .date)")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                                
                                            }
                                            .padding()
                                            .cornerRadius(10)
                                        }
                                        // Enable deleting invoices from the group
                                        .onDelete { indexSet in
                                            for index in indexSet {
                                                if let invoiceToDelete = groupedInvoices[year]?[index] {
                                                    context.delete(invoiceToDelete)
                                                }
                                            }
                                            // Save context changes
                                            do {
                                                try context.save()
                                            } catch {
                                                print("Error al guardar el contexto: \(error.localizedDescription)")
                                            }
                                        }
                                    }
                                }
                                .listRowBackground(Color.black.opacity(0.2))
                            }
                        } else {
                            // Show only the invoices filtered during the search
                            Section(header: Text("Resultados de Búsqueda")) {
                                ForEach(filteredInvoices) { invoice in
                                    VStack(alignment: .leading) {
                                        Text("Razón Social: \(invoice.razonSocial)")
                                        Text("Es Débito: \(invoice.isDebit ? "Sí" : "No")")
                                        if let numeroFactura = invoice.numeroFactura {
                                            Text("Número de Factura: \(numeroFactura)")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        Text("IVA: $\(invoice.vatRate, specifier: "%.1f")%")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        Text("Monto Total: $\(invoice.amount, specifier: "%.2f")")
                                            .foregroundStyle(Color.green)
                                        Text("Monto Neto: $\(invoice.netAmount, specifier: "%.2f")")
                                            .foregroundStyle(Color.green)
                                        Text("IVA Discriminado: $\(invoice.iva, specifier: "%.2f")")
                                            .foregroundStyle(Color("FullRedColor"))
                                        Text("Fecha: \(invoice.date, style: .date)")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        
                                    }
                                    
                                }
                            }
                            .listRowBackground(Color.black.opacity(0.2))
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
                Spacer()
                .padding()
                .navigationTitle("Facturas")
                .safeAreaPadding(.bottom, 5)
                .sheet(isPresented: $showAddBill) {
                    AddInvoiceView()
                        .environment(\.modelContext, context)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
