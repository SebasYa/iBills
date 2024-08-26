//
//  AddBillView.swift
//  iBills
//
//  Created by Sebastian Yanni on 05/08/2024.
//

import SwiftUI
import SwiftData

struct AddInvoiceView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = AddInvoiceViewModel()
    @FocusState private var invoiceNumberFocused: Bool
    @FocusState private var amountIsFocused: Bool

    var body: some View {
        NavigationView {
            Form {
                TextField("Razón Social", text: $viewModel.razonSocial)
                    .keyboardType(.asciiCapable)
                
                TextField("Numero de Factura", text: $viewModel.numeroFactura)
                    .keyboardType(.numberPad)
                    .focused($invoiceNumberFocused)

                TextField("Monto Total", text: $viewModel.amount)
                    .keyboardType(.decimalPad)
                    .focused($amountIsFocused)
                    
                
                DatePicker("Fecha", selection: $viewModel.selectedDate, displayedComponents: .date)
                
                Picker("Porcentaje de IVA", selection: $viewModel.selectedVAT) {
                    Text("27%").tag(27.0)
                    Text("21%").tag(21.0)
                    Text("10,5%").tag(10.5)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Toggle(isOn: $viewModel.isDebit) {
                    Text(viewModel.isDebit ? "I.V.A Débito" : "I.V.A Crédito")
                }
                
                Button("Agregar Factura") {
                    DispatchQueue.main.async {
                        viewModel.addInvoice()
                    }
                }
            }
            
            .navigationTitle("Agregar Factura")
            .toolbar {
                if invoiceNumberFocused || amountIsFocused{
                    Button("Done") {
                        invoiceNumberFocused = false
                        amountIsFocused = false
                    }
                }
            }
            .alert(isPresented: $viewModel.showErrorAlert) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Ocurrió un error inesperado."), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $viewModel.showSuccessAlert) {
                Alert(title: Text("Factura Agregada"), message: Text(viewModel.successMessage ?? "La factura se agregó exitosamente."), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                viewModel.setContext(context)
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Invoice.self)
    return AddInvoiceView()
        .modelContainer(container)
}
