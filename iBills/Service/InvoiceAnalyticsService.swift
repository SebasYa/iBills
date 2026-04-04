//
//  InvoiceAnalyticsService.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import Foundation

struct VATBalanceSummary {
    let totalCreditIVA: Decimal
    let totalDebitIVA: Decimal

    var netIVA: Decimal {
        InvoiceDecimal.money(from: totalCreditIVA - totalDebitIVA)
    }

    var totalCreditIVADouble: Double {
        totalCreditIVA.doubleValue
    }

    var totalDebitIVADouble: Double {
        totalDebitIVA.doubleValue
    }

    var netIVADouble: Double {
        netIVA.doubleValue
    }
}

struct InvoiceChartData {
    let groupedInvoices: [Date: [Invoice]]
    let dates: [Date]
    let cumulativeCredit: [Double]
    let cumulativeDebit: [Double]
    let cumulativeBalance: [Double]

    static let empty = InvoiceChartData(
        groupedInvoices: [:],
        dates: [],
        cumulativeCredit: [],
        cumulativeDebit: [],
        cumulativeBalance: []
    )
}

protocol InvoiceAnalyticsProviding {
    func availableYears(invoices: [Invoice]) -> [String]
    func defaultSelectedYear(from invoices: [Invoice], preferredYear: String?) -> String?
    func groupInvoicesByYear(_ invoices: [Invoice]) -> [String: [Invoice]]
    func filterInvoices(_ invoices: [Invoice], searchText: String) -> [Invoice]
    func makeBalanceSummary(for invoices: [Invoice]) -> VATBalanceSummary
    func chartData(for year: String, invoices: [Invoice]) -> InvoiceChartData
}

struct InvoiceAnalyticsService: InvoiceAnalyticsProviding {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func availableYears(invoices: [Invoice]) -> [String] {
        Array(Set(invoices.map { yearString(from: $0.date) }))
            .sorted(by: >)
    }

    func defaultSelectedYear(from invoices: [Invoice], preferredYear: String?) -> String? {
        let years = availableYears(invoices: invoices)
        guard !years.isEmpty else {
            return nil
        }

        if let preferredYear, years.contains(preferredYear) {
            return preferredYear
        }

        let currentYear = yearString(from: Date())
        if years.contains(currentYear) {
            return currentYear
        }

        return years.first
    }

    func groupInvoicesByYear(_ invoices: [Invoice]) -> [String: [Invoice]] {
        Dictionary(grouping: invoices) { invoice in
            yearString(from: invoice.date)
        }
        .mapValues { yearlyInvoices in
            yearlyInvoices.sorted { $0.date > $1.date }
        }
    }

    func filterInvoices(_ invoices: [Invoice], searchText: String) -> [Invoice] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return invoices.sorted { $0.date > $1.date }
        }

        return invoices
            .filter { invoice in
                invoice.razonSocial.localizedCaseInsensitiveContains(query) ||
                (invoice.numeroFactura?.localizedCaseInsensitiveContains(query) ?? false)
            }
            .sorted { $0.date > $1.date }
    }

    func makeBalanceSummary(for invoices: [Invoice]) -> VATBalanceSummary {
        let totalCreditIVA = invoices
            .filter { $0.category == .credit }
            .reduce(Decimal.zero) { partialResult, invoice in
                partialResult + invoice.ivaDecimal
            }

        let totalDebitIVA = invoices
            .filter { $0.category == .debit }
            .reduce(Decimal.zero) { partialResult, invoice in
                partialResult + invoice.ivaDecimal
            }

        return VATBalanceSummary(
            totalCreditIVA: InvoiceDecimal.money(from: totalCreditIVA),
            totalDebitIVA: InvoiceDecimal.money(from: totalDebitIVA)
        )
    }

    func chartData(for year: String, invoices: [Invoice]) -> InvoiceChartData {
        guard !year.isEmpty else {
            return .empty
        }

        let invoicesForYear = invoices.filter { invoice in
            yearString(from: invoice.date) == year
        }

        guard !invoicesForYear.isEmpty else {
            return .empty
        }

        let groupedInvoices = Dictionary(grouping: invoicesForYear) { invoice in
            calendar.startOfDay(for: invoice.date)
        }

        let sortedDates = groupedInvoices.keys.sorted()
        var runningCredit = Decimal.zero
        var runningDebit = Decimal.zero
        var cumulativeCredit: [Double] = []
        var cumulativeDebit: [Double] = []
        var cumulativeBalance: [Double] = []

        for date in sortedDates {
            let invoicesForDate = groupedInvoices[date, default: []]

            let creditForDate = invoicesForDate
                .filter { $0.category == .credit }
                .reduce(Decimal.zero) { $0 + $1.ivaDecimal }

            let debitForDate = invoicesForDate
                .filter { $0.category == .debit }
                .reduce(Decimal.zero) { $0 + $1.ivaDecimal }

            runningCredit = InvoiceDecimal.money(from: runningCredit + creditForDate)
            runningDebit = InvoiceDecimal.money(from: runningDebit + debitForDate)

            cumulativeCredit.append(runningCredit.doubleValue)
            cumulativeDebit.append(runningDebit.doubleValue)
            cumulativeBalance.append(InvoiceDecimal.money(from: runningCredit - runningDebit).doubleValue)
        }

        return InvoiceChartData(
            groupedInvoices: groupedInvoices,
            dates: sortedDates,
            cumulativeCredit: cumulativeCredit,
            cumulativeDebit: cumulativeDebit,
            cumulativeBalance: cumulativeBalance
        )
    }

    private func yearString(from date: Date) -> String {
        String(calendar.component(.year, from: date))
    }
}
