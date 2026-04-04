//
//  Invoice.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import Foundation
import SwiftData

@Model
final class Invoice {
    var amount: Double
    var vatRate: Double
    var isCredit: Bool
    var date: Date
    var razonSocial: String
    var numeroFactura: String?

    init(amount: Double, vatRate: Double, isCredit: Bool, date: Date, razonSocial: String, numeroFactura: String? = nil) {
        self.amount = InvoiceDecimal.money(from: amount).doubleValue
        self.vatRate = InvoiceDecimal.rate(from: vatRate).doubleValue
        self.isCredit = isCredit
        self.date = date
        self.razonSocial = razonSocial.trimmingCharacters(in: .whitespacesAndNewlines)
        self.numeroFactura = numeroFactura?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfBlank
    }

    var category: InvoiceCategory {
        InvoiceCategory(isCredit: isCredit)
    }

    var amountDecimal: Decimal {
        InvoiceDecimal.money(from: amount)
    }

    var vatRateDecimal: Decimal {
        InvoiceDecimal.rate(from: vatRate)
    }

    var netAmountDecimal: Decimal {
        InvoiceDecimal.netAmount(totalAmount: amountDecimal, vatRate: vatRateDecimal)
    }

    var ivaDecimal: Decimal {
        InvoiceDecimal.vatAmount(totalAmount: amountDecimal, vatRate: vatRateDecimal)
    }

    var netAmount: Double {
        netAmountDecimal.doubleValue
    }

    var iva: Double {
        ivaDecimal.doubleValue
    }
}

enum InvoiceDecimal {
    static func money(from value: Double) -> Decimal {
        money(from: Decimal(value))
    }

    static func money(from value: Decimal) -> Decimal {
        value.rounded(scale: 2)
    }

    static func rate(from value: Double) -> Decimal {
        rate(from: Decimal(value))
    }

    static func rate(from value: Decimal) -> Decimal {
        value.rounded(scale: 2)
    }

    static func netAmount(totalAmount: Decimal, vatRate: Decimal) -> Decimal {
        guard vatRate > 0 else {
            return money(from: totalAmount)
        }

        let divisor = Decimal(1) + (vatRate / Decimal(100))
        guard divisor != 0 else {
            return .zero
        }

        return money(from: totalAmount / divisor)
    }

    static func vatAmount(totalAmount: Decimal, vatRate: Decimal) -> Decimal {
        money(from: totalAmount - netAmount(totalAmount: totalAmount, vatRate: vatRate))
    }
}

extension Decimal {
    func rounded(scale: Int16, mode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var source = self
        var result = Decimal()
        NSDecimalRound(&result, &source, Int(scale), mode)
        return result
    }

    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}

private extension String {
    var nilIfBlank: String? {
        isEmpty ? nil : self
    }
}
