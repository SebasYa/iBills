//
//  AddInvoiceViewModel.swift
//  iBills
//
//  Created by Sebastian Yanni on 22/08/2024.
//

import SwiftData
import SwiftUI

class AddInvoiceViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var selectedVAT: Double = 21.0
    @Published var isDebit: Bool = true
    @Published var selectedDate = Date()
    @Published var razonSocial: String = ""
    @Published var numeroFactura: String = ""
    @Published var showErrorAlert = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert = false
    @Published var successMessage: String?

    private var context: ModelContext?

    func setContext(_ context: ModelContext) {
        self.context = context
    }
    
    // Adds a new invoice and saves it to the context
    func addInvoice() {
        guard let context = context else {
            errorMessage = "El contexto no está disponible."
            showErrorAlert = true
            return
        }

        guard !amount.isEmpty, let amountValue = Double(amount), amountValue > 0 else {
            errorMessage = "El monto total debe ser un número positivo."
            showErrorAlert = true
            return
        }

        guard !razonSocial.isEmpty else {
            errorMessage = "La razón social no puede estar vacía."
            showErrorAlert = true
            return
        }

        // Create the invoice
        let invoice = Invoice(
            amount: amountValue,
            vatRate: selectedVAT,
            isDebit: isDebit,
            date: selectedDate,
            razonSocial: razonSocial,
            numeroFactura: numeroFactura.isEmpty ? nil : numeroFactura
        )
        
        print("Agregar Factura:")
        print("Monto Total: \(amountValue)")
        print("Porcentaje de IVA: \(selectedVAT)")
        print("Razón Social: \(razonSocial)")
        print("Número de Factura: \(numeroFactura)")
        print("Tipo: \(isDebit ? "Débito" : "Crédito")")
        print("Fecha: \(selectedDate)")
        print("IVA Calculado: \(invoice.iva)")
        
        do {
            context.insert(invoice)
            try context.save()
            
            successMessage = "Factura agregada con éxito. IVA discriminado: \(String(format: "%.2f", invoice.iva))"
            showSuccessAlert = true
            
            clearForm()
        } catch {
            errorMessage = "No se pudo guardar la factura. Intenta nuevamente."
            showErrorAlert = true
        }
    }
    
    // Clear the form fields
    private func clearForm() {
        amount = ""
        razonSocial = ""
        numeroFactura = ""
        selectedVAT = 21.0
        isDebit = true
        selectedDate = Date()
    }
}
