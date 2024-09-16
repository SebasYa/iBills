//
//  Home.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query private var invoices: [Invoice]
    
    @StateObject private var viewModel = HomeViewModel()

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
                    // Button to add a new invoice
                    Button(action: {
                        viewModel.showAddBill.toggle()
                        viewModel.isDeleteYearMode = false
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
                            TextField("Razón Social o Número de Factura", text: $viewModel.searchText)
                                .foregroundStyle(Color.white)
                                .padding(8)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .onChange(of: viewModel.searchText) { _, _ in
                            viewModel.isDeleteYearMode = false
                        }
                        .listRowBackground(Color.clear)

                        if viewModel.searchText.isEmpty {
                            let groupedInvoices = viewModel.groupInvoicesByYear(invoices: invoices)
                            Section(header: HStack {
                                Spacer()
                                Text("Facturas por Año")
                                Spacer()
                            }) {
                                ForEach(groupedInvoices.keys.sorted(), id: \.self) { year in
                                    DisclosureGroup(year) {
                                        ForEach(groupedInvoices[year] ?? []) { invoice in
                                            InvoiceRow(invoice: invoice, disableSwipe: viewModel.isDeleteYearMode)
                                        }
                                        .listRowBackground(Color.black.opacity(0.2))
                                    }
                                    .offset(x: viewModel.isAnimatingSwipe && viewModel.isDeleteYearMode ? -30 : 0)
                                    .listRowBackground(Color.black.opacity(0.2))
                                    // Swipe action to delete the entire year
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        if viewModel.isDeleteYearMode {
                                            Button(role: .destructive) {
                                                viewModel.yearToDelete = year
                                                viewModel.showDeleteAlert = true
                                            } label: {
                                                Label("Eliminar Año", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            // Filtered invoices section
                            Section(header: Text("Resultados de Búsqueda")) {
                                ForEach(viewModel.filteredInvoices(invoices: invoices)) { invoice in
                                    InvoiceRow(invoice: invoice, disableSwipe: false)
                                }
                            }
                            .listRowBackground(Color.black.opacity(0.2))
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
                Spacer()
            }
            .navigationTitle("Facturas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.isDeleteYearMode.toggle()
                        if viewModel.isDeleteYearMode {
                            triggerSwipeAnimation()
                        }
                    }) {
                        HStack {
                            VStack {
                                Image(systemName: viewModel.isDeleteYearMode ? "checkmark.circle" : "trash")
                                    .foregroundStyle(Color.primary)
                                Text(viewModel.isDeleteYearMode ? "Terminar" : "Eliminar Años")
                                    .foregroundStyle(Color.primary)
                            }
                        }

                    }
                }
            }
            .alert(isPresented: $viewModel.showDeleteAlert) {
                Alert(
                    title: Text("Eliminar Facturas Anuales"),
                    message: Text("¿Está seguro de que desea eliminar todas las facturas del año \(viewModel.yearToDelete ?? "")? Esta acción no se puede deshacer."),
                    primaryButton: .destructive(Text("Eliminar")) {
                        if let year = viewModel.yearToDelete {
                            viewModel.deleteYearInvoices(from: year, invoicesByYear: viewModel.groupInvoicesByYear(invoices: invoices), context: context)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $viewModel.showAddBill) {
                AddInvoiceView()
                    .environment(\.modelContext, context)
            }
        }
    }

    // Trigger animation for swipe action
    private func triggerSwipeAnimation() {
        withAnimation {
            viewModel.isAnimatingSwipe = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                viewModel.isAnimatingSwipe = false
            }
        }
    }
}

#Preview {
    HomeView()
}

struct InvoiceRow: View {
    @Environment(\.modelContext) private var context
    @State private var showDeleteInvoiceAlert = false
    var invoice: Invoice
    var disableSwipe: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Razón Social:")
                Text("\(invoice.razonSocial)")
                    .foregroundStyle(Color("RazonSocialColor"))
            }
            Text("Es Crédito: \(invoice.isCredit ? "Sí" : "No")")
            if let numeroFactura = invoice.numeroFactura {
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
                    deleteInvoice(invoice)
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func deleteInvoice(_ invoice: Invoice) {
        context.delete(invoice)
        saveContext()
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error al guardar el contexto: \(error.localizedDescription)")
        }
    }
}
