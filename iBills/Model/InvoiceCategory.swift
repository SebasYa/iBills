//
//  InvoiceCategory.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import Foundation

enum InvoiceCategory: String, CaseIterable, Identifiable {
    case credit
    case debit

    var id: Self { self }

    var title: String {
        switch self {
        case .credit:
            "Crédito"
        case .debit:
            "Débito"
        }
    }

    var balanceTitle: String {
        switch self {
        case .credit:
            "IVA Crédito"
        case .debit:
            "IVA Débito"
        }
    }

    var isCredit: Bool {
        self == .credit
    }

    init(isCredit: Bool) {
        self = isCredit ? .credit : .debit
    }
}
