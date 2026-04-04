//
//  HomeViewModel.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI
import SwiftData

enum HomeDeleteTarget {
    case invoice(Invoice)
    case year(String)
    case month(year: String, month: Int, title: String)

    var title: String {
        switch self {
        case .invoice:
            "Eliminar factura"
        case .year:
            "Eliminar facturas del año"
        case .month:
            "Eliminar facturas del mes"
        }
    }

    var buttonTitle: String {
        switch self {
        case .invoice:
            "Eliminar factura"
        case let .year(year):
            "Eliminar \(year)"
        case let .month(_, _, title):
            "Eliminar \(title)"
        }
    }

    var message: String {
        switch self {
        case let .invoice(invoice):
            if let numeroFactura = invoice.numeroFactura, !numeroFactura.isEmpty {
                "Esta acción elimina la factura \(numeroFactura) de \(invoice.razonSocial) y no se puede deshacer."
            } else {
                "Esta acción elimina la factura de \(invoice.razonSocial) y no se puede deshacer."
            }
        case let .year(year):
            "Esta acción elimina todas las facturas de \(year) y no se puede deshacer."
        case let .month(year, _, title):
            "Esta acción elimina todas las facturas de \(title) \(year) y no se puede deshacer."
        }
    }
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var showAddBill = false
    @Published var searchText = ""
    @Published var showErrorAlert = false
    @Published var errorMessage: String?
    @Published var isDeleteYearMode = false
    @Published var deleteTarget: HomeDeleteTarget?

    private let analyticsService: InvoiceAnalyticsProviding
    private var invoiceStore: InvoiceStoring?

    init(analyticsService: InvoiceAnalyticsProviding = InvoiceAnalyticsService()) {
        self.analyticsService = analyticsService
    }

    func setContext(_ context: ModelContext) {
        invoiceStore = SwiftDataInvoiceStore(context: context)
    }

    func homeSections(from invoices: [Invoice]) -> [InvoiceYearSection] {
        let filteredInvoices = analyticsService.filterInvoices(invoices, searchText: searchText)
        return analyticsService.makeHomeSections(from: filteredInvoices)
    }

    func allHomeSections(from invoices: [Invoice]) -> [InvoiceYearSection] {
        analyticsService.makeHomeSections(from: invoices)
    }

    func requestDeleteYear(_ year: String) {
        deleteTarget = .year(year)
    }

    func requestDeleteMonth(year: String, month: Int, title: String) {
        deleteTarget = .month(year: year, month: month, title: title)
    }

    func requestDeleteInvoice(_ invoice: Invoice) {
        deleteTarget = .invoice(invoice)
    }

    func clearDeleteTarget() {
        deleteTarget = nil
    }

    func confirmDeletion(from invoices: [Invoice]) {
        guard let invoiceStore else {
            presentError("No se pudo acceder al almacenamiento de facturas.")
            return
        }

        guard let deleteTarget else {
            return
        }

        clearDeleteTarget()

        let invoicesToDelete: [Invoice]
        switch deleteTarget {
        case let .invoice(invoice):
            invoicesToDelete = [invoice]
        case let .year(year):
            invoicesToDelete = analyticsService.invoices(in: year, month: nil, from: invoices)
        case let .month(year, month, _):
            invoicesToDelete = analyticsService.invoices(in: year, month: month, from: invoices)
        }

        guard !invoicesToDelete.isEmpty else {
            return
        }

        do {
            try invoiceStore.delete(invoicesToDelete)
        } catch {
            presentError("No se pudieron eliminar las facturas. \(error.localizedDescription)")
        }
    }

    private func presentError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }
}
