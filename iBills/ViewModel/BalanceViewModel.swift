//
//  BalanceViewModel.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI

enum BalanceStatus {
    case favorable
    case payable
    case neutral
}

struct BalanceInsights {
    let invoiceCount: Int
    let creditInvoiceCount: Int
    let debitInvoiceCount: Int
    let averageIVA: Decimal
    let creditNetAmount: Decimal
    let debitNetAmount: Decimal
    let status: BalanceStatus
    let absoluteNetIVA: Decimal
}

final class BalanceViewModel: ObservableObject {
    private let analyticsService: InvoiceAnalyticsProviding

    init(analyticsService: InvoiceAnalyticsProviding = InvoiceAnalyticsService()) {
        self.analyticsService = analyticsService
    }

    func availableYears(from invoices: [Invoice]) -> [String] {
        analyticsService.availableYears(invoices: invoices)
    }

    func defaultSelectedYear(from invoices: [Invoice], preferredYear: String?) -> String {
        analyticsService.defaultSelectedYear(from: invoices, preferredYear: preferredYear) ?? ""
    }

    func invoices(for year: String, from invoices: [Invoice]) -> [Invoice] {
        analyticsService.invoices(in: year, month: nil, from: invoices)
    }

    func summary(for invoices: [Invoice]) -> VATBalanceSummary {
        analyticsService.makeBalanceSummary(for: invoices)
    }

    func insights(for invoices: [Invoice], summary: VATBalanceSummary) -> BalanceInsights {
        let creditInvoices = invoices.filter { $0.category == .credit }
        let debitInvoices = invoices.filter { $0.category == .debit }

        let totalIVA = invoices.reduce(Decimal.zero) { partialResult, invoice in
            partialResult + invoice.ivaDecimal
        }

        let creditNetAmount = creditInvoices.reduce(Decimal.zero) { partialResult, invoice in
            partialResult + invoice.netAmountDecimal
        }

        let debitNetAmount = debitInvoices.reduce(Decimal.zero) { partialResult, invoice in
            partialResult + invoice.netAmountDecimal
        }

        let averageIVA: Decimal
        if invoices.isEmpty {
            averageIVA = .zero
        } else {
            averageIVA = InvoiceDecimal.money(from: totalIVA / Decimal(invoices.count))
        }

        let status: BalanceStatus
        if summary.netIVA > .zero {
            status = .favorable
        } else if summary.netIVA < .zero {
            status = .payable
        } else {
            status = .neutral
        }

        let absoluteNetIVA = InvoiceDecimal.money(
            from: summary.netIVA < .zero ? -summary.netIVA : summary.netIVA
        )

        return BalanceInsights(
            invoiceCount: invoices.count,
            creditInvoiceCount: creditInvoices.count,
            debitInvoiceCount: debitInvoices.count,
            averageIVA: averageIVA,
            creditNetAmount: InvoiceDecimal.money(from: creditNetAmount),
            debitNetAmount: InvoiceDecimal.money(from: debitNetAmount),
            status: status,
            absoluteNetIVA: absoluteNetIVA
        )
    }
}
