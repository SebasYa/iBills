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
    
    @State private var showDeleteAlert = false
    @State private var yearToDelete: String?

    // State variables to manage year deletion mode and swipe animation
    @State private var isDeleteMode = false
    @State private var isAnimatingSwipe = false
    
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

    // Function to delete all invoices from a specific year
        private func deleteInvoices(from year: String) {
            guard let invoicesToDelete = groupedInvoices[year] else { return }
            for invoice in invoicesToDelete {
                context.delete(invoice)
            }
            do {
                try context.save()
            } catch {
                print("Error al guardar el contexto: \(error.localizedDescription)")
            }
        }
    
    // Function to trigger the swipe animation for year deletion
    private func triggerSwipeAnimation() {
        withAnimation {
            isAnimatingSwipe = true
        }
        // Automatically reset the animation after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                isAnimatingSwipe = false
            }
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
                        isDeleteMode = false
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
                                .onChange(of: searchText) { _, newValue in
                                    isDeleteMode = false
                                }
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
                                    // Swipe to delete the entire year
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        if isDeleteMode {
                                            Button(role: .destructive) {
                                                yearToDelete = year
                                                showDeleteAlert = true
                                            } label: {
                                                Label("Eliminar", systemImage: "trash")
                                            }
                                        }
                                    }
                                    .offset(x: isAnimatingSwipe && isDeleteMode ? -30 : 0)
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
                .toolbar {
                    // Config button to enable year deletion
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isDeleteMode.toggle()
                            if isDeleteMode {
                                triggerSwipeAnimation()
                            }
                        }) {
                            Image(systemName: isDeleteMode ? "checkmark.circle" : "trash")
                        }
                    }
                }
                .alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text("Eliminar Facturas"),
                        message: Text("¿Está seguro de que desea eliminar todas las facturas del año \(yearToDelete ?? "")? Esta acción no se puede deshacer."),
                        primaryButton: .destructive(Text("Eliminar")) {
                            if let year = yearToDelete {
                                deleteInvoices(from: year)
                            }
                        },
                        secondaryButton: .cancel(Text("Cancelar"))
                    )
                }
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
