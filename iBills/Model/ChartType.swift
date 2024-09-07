//
//  ChartType.swift
//  iBills
//
//  Created by Sebastian Yanni.
//


import Foundation

enum ChartType: CaseIterable {
    case debit
    case difference
    case credit
    
    
    var title: String {
        switch self {
        case .debit: return "Débito"
        case .difference: return "Diferencia"
        case .credit: return "Crédito"
        }
    }
}
