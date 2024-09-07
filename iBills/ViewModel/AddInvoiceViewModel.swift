//
//  AddInvoiceViewModel.swift
//  iBills
//
//  Created by Sebastian Yanni.
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
    
    @Published var showAlert = false
    @Published var showErrorAlert = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private var context: ModelContext?

    func setContext(_ context: ModelContext) {
        self.context = context
    }
    
    private func allFieldsFilled() -> Bool {
        return !amount.isEmpty && !razonSocial.isEmpty && !numeroFactura.isEmpty
    }
    
    // Adds a new invoice and saves it to the context
    func addInvoice() {
        guard let context = context else {
            errorMessage = "Error interno: el contexto no está disponible."
            showErrorAlert = true
            showAlert = true
            return
        }
        
        guard allFieldsFilled() else {
            errorMessage = "Por favor, complete todos los campos para agregar la factura."
            showErrorAlert = true
            showAlert = true
            print("Error: Falta completar campos del formulario.")
            return
        }

        // Convert amount to Double
        guard let amountValue = Double(amount), amountValue > 0 else {
            errorMessage = "El monto total debe ser un número positivo."
            showErrorAlert = true
            showAlert = true
            return
        }

        // Create the invoice
        let invoice = Invoice(
            amount: amountValue,
            vatRate: selectedVAT,
            isDebit: isDebit,
            date: selectedDate,
            razonSocial: razonSocial,
            numeroFactura: numeroFactura
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
            showErrorAlert = false
            showAlert = true
            print("Factura guardada exitosamente: \(invoice)")
            
            clearForm()
        } catch {
            errorMessage = "No se pudo guardar la factura. Intenta nuevamente: \(error.localizedDescription)"
            showErrorAlert = true
            showAlert = true
            print("Error al guardar la factura: \(error.localizedDescription)")
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
