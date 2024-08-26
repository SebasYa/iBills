//
//  BalanceViewModel.swift
//  iBills
//
//  Created by Sebastian Yanni on 24/08/2024.
//

import SwiftUI
import SwiftData

class BalanceViewModel: ObservableObject {
    func totalDebitIVA(invoices: [Invoice]) -> Double {
        return invoices.filter { $0.isDebit }.reduce(0) { $0 + $1.iva }
    }
    
    func totalCreditIVA(invoices: [Invoice]) -> Double {
        return invoices.filter { !$0.isDebit }.reduce(0) { $0 + $1.iva }
    }
    
    func netIVA(invoices: [Invoice]) -> Double {
        return totalDebitIVA(invoices: invoices) - totalCreditIVA(invoices: invoices)
    }
}
