//
//  InvoiceStore.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import Foundation
import SwiftData

protocol InvoiceStoring {
    func insert(_ invoice: Invoice) throws
    func delete(_ invoice: Invoice) throws
    func delete(_ invoices: [Invoice]) throws
}

struct SwiftDataInvoiceStore: InvoiceStoring {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func insert(_ invoice: Invoice) throws {
        context.insert(invoice)
        try context.save()
    }

    func delete(_ invoice: Invoice) throws {
        context.delete(invoice)
        try context.save()
    }

    func delete(_ invoices: [Invoice]) throws {
        invoices.forEach { context.delete($0) }
        try context.save()
    }
}
