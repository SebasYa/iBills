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
    @Query private var receipts: [Receipt]
    
    @State private var showAddReceipt = false
    @State private var showAddBill = false
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Facturas")) {
                        Button("Agregar Factura") {
                            showAddBill.toggle()
                        }
                        List {
                            ForEach(invoices) { invoice in
                                VStack(alignment: .leading) {
                                    Text("Tipo: \(invoice.type)")
                                    Text("Monto Total: \(invoice.amount, specifier: "%.2f")")
                                    Text("Monto Neto: \(invoice.netAmount, specifier: "%.2f")")
                                    Text("IVA: \(invoice.iva, specifier: "%.2f")")
                                    Text("Fecha: \(invoice.date, style: .date)")
                                    Text("Es Débito: \(invoice.isDebit ? "Sí" : "No")")
                                }
                            }
                            .onDelete{ indexSet in
                                for index in indexSet {
                                    let invoiceToDelete = invoices[index]
                                    context.delete(invoiceToDelete)
                                }
                                do {
                                    try context.save()
                                } catch {
                                    print("Error al guardar el contexto: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Remitos")) {
                        Button("Agregar Remito") {
                            showAddReceipt.toggle()
                        }
                        List {
                            ForEach(receipts) { receipts in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Descripción: \(receipts.explanation)")
                                        Text("Fecha: \(receipts.date, style: .date)")
                                    }
                                    Spacer()
                                    if receipts.alarmSet {
                                        Image(systemName: "bell.fill")
                                    } else {
                                        Image(systemName: "bell.slash.fill")
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    let receiptToDelete = receipts[index]
                                    context.delete(receiptToDelete)
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
            }
            .padding()
            .navigationTitle("Agrega Registros")
            .sheet(isPresented: $showAddBill) {
                AddInvoiceView()
                    .environment(\.modelContext, context)
            }
            .sheet(isPresented: $showAddReceipt) {
                AddReceiptView()
                    .environment(\.modelContext, context)
        }
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


#Preview {
    HomeView()
}
