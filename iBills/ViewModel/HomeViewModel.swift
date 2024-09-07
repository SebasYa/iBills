//
//  HomeViewModel.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI
import SwiftData

class HomeViewModel: ObservableObject {
    @Published var showAddBill = false
    @Published var searchText = ""
    @Published var showDeleteAlert = false
    @Published var showDeleteInvoiceAlert = false
    @Published var yearToDelete: String?
    @Published var invoiceToDelete: Invoice?
    
    @Published var isDeleteYearMode = false
    @Published var isAnimatingSwipe = false
    
    // Group invoices by year
    func groupInvoicesByYear(invoices: [Invoice]) -> [String: [Invoice]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        
        let groupedInvoices = Dictionary(grouping: invoices) { invoice in
            dateFormatter.string(from: invoice.date)
        }
        
        return groupedInvoices.mapValues { invoices in
            invoices.sorted { $0.date < $1.date } // Orden ascendente por fecha (antigua a reciente)
        }
    }
    
    // Filter invoices based on search text
    func filteredInvoices(invoices: [Invoice]) -> [Invoice] {
        let filtered = invoices.filter { invoice in
            invoice.razonSocial.localizedCaseInsensitiveContains(searchText) ||
            (invoice.numeroFactura?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
        return filtered.sorted { $0.date < $1.date }
    }
    
    
    // Delete all invoices for a specific year
    func deleteYearInvoices(from year: String, invoicesByYear: [String: [Invoice]], context: ModelContext) {
        if let invoicesToDelete = invoicesByYear[year] {
            invoicesToDelete.forEach { context.delete($0) }
        }
        saveContext(context)
    }
    
    // Save the context to persist changes
    func saveContext(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("Error al guardar el contexto: \(error.localizedDescription)")
        }
    }
}
