//
//  ChartType.swift
//  iBills
//
//  Created by Sebastian Yanni.
//


import Foundation

enum ChartType: CaseIterable {
    case credit
    case difference
    case debit
    
    
    var title: String {
        switch self {
        case .credit: return "Crédito"
        case .difference: return "Diferencia"
        case .debit: return "Débito"
        }
    }
}
