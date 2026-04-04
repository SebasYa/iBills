//
//  PreviewFixtures.swift
//  iBills
//
//  Created by Sebastian Yanni on 04/04/2026.
//

import Foundation

enum PreviewFixtures {
    static func invoices() -> [Invoice] {
        [
            Invoice(
                amount: 1210,
                vatRate: 21,
                isCredit: true,
                date: date(year: 2026, month: 4, day: 12),
                razonSocial: "Acme S.A.",
                numeroFactura: "A-0001-00001234"
            ),
            Invoice(
                amount: 605,
                vatRate: 21,
                isCredit: false,
                date: date(year: 2026, month: 4, day: 5),
                razonSocial: "Mercurio SRL",
                numeroFactura: "B-0002-00000098"
            ),
            Invoice(
                amount: 1105,
                vatRate: 10.5,
                isCredit: true,
                date: date(year: 2026, month: 3, day: 18),
                razonSocial: "Delta SAS",
                numeroFactura: "A-0003-00000456"
            ),
            Invoice(
                amount: 2420,
                vatRate: 21,
                isCredit: false,
                date: date(year: 2026, month: 3, day: 2),
                razonSocial: "Atlas S.A.",
                numeroFactura: "B-0004-00000812"
            )
        ]
    }

    static func monthSection() -> InvoiceMonthSection {
        let monthInvoices = invoices().filter {
            Calendar(identifier: .gregorian).component(.month, from: $0.date) == 4
        }

        return InvoiceMonthSection(
            year: "2026",
            month: 4,
            title: "Abril 2026",
            invoices: monthInvoices
        )
    }

    static func yearSection() -> InvoiceYearSection {
        let allInvoices = invoices()

        let april = InvoiceMonthSection(
            year: "2026",
            month: 4,
            title: "Abril 2026",
            invoices: allInvoices.filter {
                Calendar(identifier: .gregorian).component(.month, from: $0.date) == 4
            }
        )

        let march = InvoiceMonthSection(
            year: "2026",
            month: 3,
            title: "Marzo 2026",
            invoices: allInvoices.filter {
                Calendar(identifier: .gregorian).component(.month, from: $0.date) == 3
            }
        )

        let totalAmount = allInvoices.reduce(Decimal.zero) { partialResult, invoice in
            partialResult + invoice.amountDecimal
        }

        return InvoiceYearSection(
            year: "2026",
            invoiceCount: allInvoices.count,
            totalAmount: InvoiceDecimal.money(from: totalAmount),
            months: [april, march]
        )
    }

    static func homeSections() -> [InvoiceYearSection] {
        [yearSection()]
    }

    static func balanceSummary() -> VATBalanceSummary {
        VATBalanceSummary(
            totalCreditIVA: Decimal(string: "315.00") ?? .zero,
            totalDebitIVA: Decimal(string: "525.00") ?? .zero
        )
    }

    static func balanceInsights() -> BalanceInsights {
        BalanceInsights(
            invoiceCount: 4,
            creditInvoiceCount: 2,
            debitInvoiceCount: 2,
            averageIVA: Decimal(string: "210.00") ?? .zero,
            creditNetAmount: Decimal(string: "2000.00") ?? .zero,
            debitNetAmount: Decimal(string: "2500.00") ?? .zero,
            status: .payable,
            absoluteNetIVA: Decimal(string: "210.00") ?? .zero
        )
    }

    private static func date(year: Int, month: Int, day: Int) -> Date {
        Calendar(identifier: .gregorian).date(
            from: DateComponents(year: year, month: month, day: day)
        ) ?? .now
    }
}
