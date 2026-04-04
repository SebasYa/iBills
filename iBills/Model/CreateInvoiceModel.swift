//
//  CreateInvoiceModel.swift
//  iBills
//
//  Created by Sebastian Yanni on 18/10/2024.
//

import Foundation

enum CreateInvoiceModel: Int, Hashable, CaseIterable {
    case razonSocial
    case numeroDeFacturas
    case montoTotal

    var next: CreateInvoiceModel {
        CreateInvoiceModel(rawValue: rawValue + 1) ?? self
    }

    var previous: CreateInvoiceModel {
        CreateInvoiceModel(rawValue: rawValue - 1) ?? self
    }
}
