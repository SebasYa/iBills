//
//  TabModel.swift
//  iBills
//
//

import SwiftUI

enum TabModel: String, CaseIterable {
    case home = "house.fill"
    case balance = "book.pages.fill"
    case graficos = "chart.xyaxis.line"
    
    var title: String {
        switch self {
        case .home:
            "Home"
        case .balance:
            "Balance"
        case .graficos:
            "Gráficos"
        }
    }
}

