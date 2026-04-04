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
                            let groupedInvoices = viewModel.groupedInvoices(byYearFrom: invoices)
                            Section(header: HStack {
                                Spacer()
                                Text("Facturas por Año")
                                Spacer()
                            }) {
                                ForEach(viewModel.sortedYears(from: invoices), id: \.self) { year in
                                    DisclosureGroup(year) {
                                        ForEach(groupedInvoices[year] ?? []) { invoice in
                                            InvoiceRowView(
                                                invoice: invoice,
                                                disableSwipe: viewModel.isDeleteYearMode,
                                                onDelete: { invoice in
                                                    viewModel.deleteInvoice(invoice)
                                                }
                                            )
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
                                ForEach(viewModel.filteredInvoices(from: invoices)) { invoice in
                                    InvoiceRowView(
                                        invoice: invoice,
                                        disableSwipe: false,
                                        onDelete: { invoice in
                                            viewModel.deleteInvoice(invoice)
                                        }
                                    )
                                }
                            }
                            .listRowBackground(Color.black.opacity(0.2))
                        }
                    }
                    .alert("Error", isPresented: $viewModel.showErrorAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text(viewModel.errorMessage ?? "Ocurrió un error inesperado.")
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
                        Image(systemName: viewModel.isDeleteYearMode ? "checkmark.circle" : "trash")
                            .foregroundStyle(Color.primary)
                    }
                }
            }
            .alert(isPresented: $viewModel.showDeleteAlert) {
                Alert(
                    title: Text("Eliminar Facturas Anuales"),
                    message: Text("¿Está seguro de que desea eliminar todas las facturas del año \(viewModel.yearToDelete ?? "")? Esta acción no se puede deshacer."),
                    primaryButton: .destructive(Text("Eliminar")) {
                        if let year = viewModel.yearToDelete {
                            viewModel.deleteYearInvoices(from: year, invoices: invoices)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $viewModel.showAddBill) {
                AddInvoiceView()
                    .environment(\.modelContext, context)
            }
            .onAppear {
                viewModel.setContext(context)
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

