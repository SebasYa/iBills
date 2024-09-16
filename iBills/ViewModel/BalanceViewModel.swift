//
//  BalanceViewModel.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI
import SwiftData

class BalanceViewModel: ObservableObject {
    // Calculates the total debit IVA from a list of invoices
    func totalDebitIVA(invoices: [Invoice]) -> Double {
        return invoices.filter { $0.isCredit }.reduce(0) { $0 + $1.iva }
    }
    
    // Calculates the total credit IVA from a list of invoices
    func totalCreditIVA(invoices: [Invoice]) -> Double {
        return invoices.filter { !$0.isCredit }.reduce(0) { $0 + $1.iva }
    }
    
    // Calculates the net IVA (debit IVA - credit IVA)
    func netIVA(invoices: [Invoice]) -> Double {
        return totalCreditIVA(invoices: invoices) - totalDebitIVA(invoices: invoices)
    }
}
