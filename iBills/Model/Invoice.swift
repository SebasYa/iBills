//
//  Invoice.swift
//  iBills
//
//

import SwiftUI
import SwiftData

@Model
class Invoice {
    var amount: Double
    var vatRate: Double
    var isDebit: Bool
    var date: Date
    var razonSocial: String
    var numeroFactura: String?

    init(amount: Double, vatRate: Double, isDebit: Bool, date: Date, razonSocial: String, numeroFactura: String? = nil) {
        self.amount = amount
        self.vatRate = vatRate
        self.isDebit = isDebit
        self.date = date
        self.razonSocial = razonSocial
        self.numeroFactura = numeroFactura
    }

    var netAmount: Double {
        return amount / (1 + vatRate / 100)
    }

    var iva: Double {
        return amount - netAmount
    }

    var discriminatedVAT: Double {
        return iva
    }
}
