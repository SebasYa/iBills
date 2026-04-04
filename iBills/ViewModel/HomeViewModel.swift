//
//  HomeViewModel.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI
import SwiftData

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var showAddBill = false
    @Published var searchText = ""
    @Published var showDeleteAlert = false
    @Published var showErrorAlert = false
    @Published var yearToDelete: String?
    @Published var errorMessage: String?
    @Published var isDeleteYearMode = false
    @Published var isAnimatingSwipe = false

    private let analyticsService: InvoiceAnalyticsProviding
    private var invoiceStore: InvoiceStoring?

    init(analyticsService: InvoiceAnalyticsProviding = InvoiceAnalyticsService()) {
        self.analyticsService = analyticsService
    }

    func setContext(_ context: ModelContext) {
        invoiceStore = SwiftDataInvoiceStore(context: context)
    }

    func groupedInvoices(byYearFrom invoices: [Invoice]) -> [String: [Invoice]] {
        analyticsService.groupInvoicesByYear(invoices)
    }

    func sortedYears(from invoices: [Invoice]) -> [String] {
        analyticsService.availableYears(invoices: invoices)
    }

    func filteredInvoices(from invoices: [Invoice]) -> [Invoice] {
        analyticsService.filterInvoices(invoices, searchText: searchText)
    }

    func deleteYearInvoices(from year: String, invoices: [Invoice]) {
        guard let invoiceStore else {
            presentError("No se pudo acceder al almacenamiento de facturas.")
            return
        }

        let invoicesByYear = analyticsService.groupInvoicesByYear(invoices)
        let invoicesToDelete = invoicesByYear[year, default: []]

        guard !invoicesToDelete.isEmpty else {
            return
        }

        do {
            try invoiceStore.delete(invoicesToDelete)
            yearToDelete = nil
        } catch {
            presentError("No se pudieron eliminar las facturas del año \(year). \(error.localizedDescription)")
        }
    }

    func deleteInvoice(_ invoice: Invoice) {
        guard let invoiceStore else {
            presentError("No se pudo acceder al almacenamiento de facturas.")
            return
        }

        do {
            try invoiceStore.delete(invoice)
        } catch {
            presentError("No se pudo eliminar la factura. \(error.localizedDescription)")
        }
    }

    private func presentError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }
}
