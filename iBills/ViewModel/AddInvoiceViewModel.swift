//
//  AddInvoiceViewModel.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftData
import SwiftUI

@MainActor
final class AddInvoiceViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var selectedVAT: Double = 21.0
    @Published var selectedCategory: InvoiceCategory = .credit
    @Published var selectedDate = Date()
    @Published var razonSocial: String = ""
    @Published var numeroFactura: String = ""

    @Published var showAlert = false
    @Published var showErrorAlert = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let invoiceCreator: InvoiceCreating
    private var invoiceStore: InvoiceStoring?

    init(invoiceCreator: InvoiceCreating = InvoiceFormService()) {
        self.invoiceCreator = invoiceCreator
    }

    func setContext(_ context: ModelContext) {
        invoiceStore = SwiftDataInvoiceStore(context: context)
    }

    var isCreditSelection: Bool {
        get { selectedCategory == .credit }
        set { selectedCategory = newValue ? .credit : .debit }
    }

    var categoryTitle: String {
        selectedCategory.balanceTitle
    }

    func addInvoice() {
        guard let invoiceStore else {
            presentError("Error interno: el contexto no está disponible.")
            return
        }

        let draft = InvoiceDraft(
            razonSocial: razonSocial,
            numeroFactura: numeroFactura,
            amountText: amount,
            vatRate: selectedVAT,
            category: selectedCategory,
            date: selectedDate
        )

        do {
            let invoice = try invoiceCreator.makeInvoice(from: draft)
            try invoiceStore.insert(invoice)

            errorMessage = nil
            successMessage = "Factura agregada con éxito. IVA discriminado: \(formattedAmount(invoice.ivaDecimal))"
            showErrorAlert = false
            showAlert = true
            clearForm()
        } catch let error as InvoiceDraftError {
            presentError(error.errorDescription ?? "No se pudo validar la factura.")
        } catch {
            presentError("No se pudo guardar la factura. Intenta nuevamente: \(error.localizedDescription)")
        }
    }

    private func clearForm() {
        amount = ""
        razonSocial = ""
        numeroFactura = ""
        selectedVAT = 21.0
        selectedCategory = .credit
        selectedDate = Date()
    }

    private func presentError(_ message: String) {
        errorMessage = message
        successMessage = nil
        showErrorAlert = true
        showAlert = true
    }

    private func formattedAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "\(amount.doubleValue)"
    }
}
