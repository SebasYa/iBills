//
//  GraphViewModel.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI

@MainActor
final class GraphViewModel: ObservableObject {
    @Published private(set) var invoices: [Invoice]
    @Published var selectedChartType: ChartType = .credit
    @Published var selectedYear: String = ""
    @Published var selectedDebitDate: Date? = nil
    @Published var selectedCreditDate: Date? = nil
    @Published var selectedBalanceDate: Date? = nil
    @Published var selectedDebitIndex: Int? = nil
    @Published var selectedCreditIndex: Int? = nil
    @Published var selectedBalanceIndex: Int? = nil
    @Published var availableYears: [String] = []
    @Published private(set) var chartData: InvoiceChartData = .empty

    private let analyticsService: InvoiceAnalyticsProviding

    init(
        invoices: [Invoice] = [],
        analyticsService: InvoiceAnalyticsProviding = InvoiceAnalyticsService()
    ) {
        self.invoices = invoices
        self.analyticsService = analyticsService
        refreshState()
    }

    var cachedGroupedInvoices: [Date: [Invoice]] {
        chartData.groupedInvoices
    }

    var cachedAllDates: [Date] {
        chartData.dates
    }

    var cachedCumulativeDebit: [Double] {
        chartData.cumulativeDebit
    }

    var cachedCumulativeCredit: [Double] {
        chartData.cumulativeCredit
    }

    var cachedCumulativeBalance: [Double] {
        chartData.cumulativeBalance
    }

    func updateInvoices(invoices: [Invoice]) {
        self.invoices = invoices
        refreshState()
    }

    func selectYear(_ year: String) {
        guard selectedYear != year else {
            return
        }

        selectedYear = year
        resetSelections()
        refreshChartData()
    }

    private func refreshState() {
        availableYears = analyticsService.availableYears(invoices: invoices)
        selectedYear = analyticsService.defaultSelectedYear(from: invoices, preferredYear: selectedYear) ?? ""
        resetSelections()
        refreshChartData()
    }

    private func refreshChartData() {
        chartData = analyticsService.chartData(for: selectedYear, invoices: invoices)
    }

    private func resetSelections() {
        selectedDebitDate = nil
        selectedCreditDate = nil
        selectedBalanceDate = nil
        selectedDebitIndex = nil
        selectedCreditIndex = nil
        selectedBalanceIndex = nil
    }
}
