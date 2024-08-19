//
//  Invoice.swift
//  iBills
//
//  Created by Sebastian Yanni on 05/08/2024.
//

import SwiftUI
import SwiftData

@Model
class Invoice {
    
    
    var type: String
    var amount: Double
    var isDebit: Bool
    var date: Date
    var relatedReceiptID: UUID?
    
    init(type: String, amount: Double, isDebit: Bool, date: Date, relatedReceiptID: UUID? = nil) {
        self.type = type
        self.amount = amount
        self.isDebit = isDebit
        self.date = date
        self.relatedReceiptID = relatedReceiptID
    }
    
    
    var netAmount: Double {
        switch type {
            
        case "A":
            let rate = 0.21
            return amount / (1 + rate)
            
        case "B":
            let rate = 0.105
            return amount / (1 + rate)
            
        case "C":
            return 0
            
        default:
            return 0
        }
    }
    
    var iva: Double {
        return amount - netAmount
    }
    
    var discriminatedVAT: Double {
        return iva
    }
}
