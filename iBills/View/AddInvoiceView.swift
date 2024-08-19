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
    @State private var amount: String = ""
    @State private var selectedType: String = "A"
    @State private var isDebit: Bool = true
    @State private var selectedDate = Date()
    @State private var showErrorAlert = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false
    @State private var successMessage: String?

    
    var body: some View {
        NavigationView {
            Form {
                TextField("Monto Total", text: $amount)
                    .keyboardType(.decimalPad)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            HStack {
                                Spacer()
                                Button("Done") {
                                    hideKeyboard()
                                }
                                .padding()
                            }
                        }
                    }
                
                DatePicker("Fecha", selection: $selectedDate, displayedComponents: .date)
                
                Picker("Tipo de Factura", selection: $selectedType) {
                    Text("A").tag("A")
                    Text("B").tag("B")
                    Text("C").tag("C")
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Toggle("Es Débito", isOn: $isDebit)
                
                Button("Agregar Factura") {
                    addInvoice()
                }
            }
            .navigationTitle("Agregar Factura")
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "Ocurrió un error inesperado."), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showSuccessAlert) {
                Alert(title: Text("Factura Agregada"), message: Text(successMessage ?? "La factura se agregó exitosamente."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func addInvoice() {
        guard !amount.isEmpty, let amountValue = Double(amount), amountValue > 0 else {
            errorMessage = "El monto total debe ser un número positivo."
            showErrorAlert = true
            return
        }
        
        let invoice = Invoice(type: selectedType, amount: amountValue, isDebit: isDebit, date: selectedDate, relatedReceiptID: nil)
        
        do {
            context.insert(invoice)
            try context.save()
            
            // Calcular el IVA discriminado
            let vatAmount = invoice.discriminatedVAT
            
            // Usa String(format:) para formatear el IVA con dos decimales
            successMessage = "Factura agregada con éxito. IVA discriminado: \(String(format: "%.2f", vatAmount))"
            showSuccessAlert = true
            
            // Limpiar los campos
            self.amount = ""
        } catch {
            errorMessage = "No se pudo guardar la factura. Intenta nuevamente."
            showErrorAlert = true
        }
    }
    
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    AddInvoiceView()
}
