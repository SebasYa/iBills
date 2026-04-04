//
//  ChartType.swift
//  iBills
//
//  Created by Sebastian Yanni.
//


import Foundation

enum ChartType: CaseIterable {
    case credit
    case balance
    case debit
    
    
    var title: String {
        switch self {
        case .credit: return "Crédito"
        case .balance: return "Balance"
        case .debit: return "Débito"
        }
    }
}
