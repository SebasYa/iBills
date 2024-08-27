//
//  ChartType.swift
//  iBills
//
//  Created by Sebastian Yanni on 19/08/2024.
//

//import Foundation
//
//enum ChartType {
//    case debit
//    case credit
//    case difference
//}

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
