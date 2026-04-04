//
//  GraphViewModel.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI

struct GraphOverview {
    let title: String
    let periodText: String
    let latestValue: Decimal
    let peakValue: Decimal
    let movementCount: Int
}

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
    private let calendar = Calendar.current

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

    private var cachedDailyCredit: [Double] {
        dailyValues(for: .credit)
    }

    private var cachedDailyDebit: [Double] {
        dailyValues(for: .debit)
    }

    private var cachedDailyBalance: [Double] {
        dailyBalanceValues()
    }

    var selectedSeriesDates: [Date] {
        switch selectedChartType {
        case .credit:
            filteredSeries(
                dates: cachedAllDates,
                cumulative: cachedCumulativeCredit,
                daily: cachedDailyCredit,
                keepsZeroDailyValues: false
            ).dates
        case .balance:
            filteredSeries(
                dates: cachedAllDates,
                cumulative: cachedCumulativeBalance,
                daily: cachedDailyBalance,
                keepsZeroDailyValues: true
            ).dates
        case .debit:
            filteredSeries(
                dates: cachedAllDates,
                cumulative: cachedCumulativeDebit,
                daily: cachedDailyDebit,
                keepsZeroDailyValues: false
            ).dates
        }
    }

    var selectedSeriesData: [Double] {
        switch selectedChartType {
        case .credit:
            filteredSeries(
                dates: cachedAllDates,
                cumulative: cachedCumulativeCredit,
                daily: cachedDailyCredit,
                keepsZeroDailyValues: false
            ).cumulative
        case .balance:
            filteredSeries(
                dates: cachedAllDates,
                cumulative: cachedCumulativeBalance,
                daily: cachedDailyBalance,
                keepsZeroDailyValues: true
            ).cumulative
        case .debit:
            filteredSeries(
                dates: cachedAllDates,
                cumulative: cachedCumulativeDebit,
                daily: cachedDailyDebit,
                keepsZeroDailyValues: false
            ).cumulative
        }
    }

    var selectedDailySeriesData: [Double] {
        switch selectedChartType {
        case .credit:
            filteredSeries(
                dates: cachedAllDates,
                cumulative: cachedCumulativeCredit,
                daily: cachedDailyCredit,
                keepsZeroDailyValues: false
            ).daily
        case .balance:
            filteredSeries(
                dates: cachedAllDates,
                cumulative: cachedCumulativeBalance,
                daily: cachedDailyBalance,
                keepsZeroDailyValues: true
            ).daily
        case .debit:
            filteredSeries(
                dates: cachedAllDates,
                cumulative: cachedCumulativeDebit,
                daily: cachedDailyDebit,
                keepsZeroDailyValues: false
            ).daily
        }
    }

    var selectedSeriesTitle: String {
        switch selectedChartType {
        case .credit:
            "IVA Crédito"
        case .balance:
            "Balance IVA"
        case .debit:
            "IVA Débito"
        }
    }

    var selectedSeriesDetailTitle: String {
        switch selectedChartType {
        case .balance:
            "Balance del día"
        case .credit, .debit:
            "IVA del día"
        }
    }

    var selectedSeriesColor: Color {
        switch selectedChartType {
        case .credit:
            .green
        case .balance:
            .indigo
        case .debit:
            .red
        }
    }

    var chartDomain: ClosedRange<Date>? {
        guard let selectedYearValue = Int(selectedYear),
              let start = calendar.date(from: DateComponents(year: selectedYearValue, month: 1, day: 1)),
              let end = calendar.date(from: DateComponents(year: selectedYearValue, month: 12, day: 31)) else {
            return nil
        }

        return start...end
    }

    var overview: GraphOverview? {
        guard let firstDate = selectedSeriesDates.first,
              let lastDate = selectedSeriesDates.last,
              let latestValue = selectedSeriesData.last else {
            return nil
        }

        let peakValue = selectedSeriesData.max() ?? latestValue

        return GraphOverview(
            title: selectedSeriesTitle,
            periodText: Self.periodFormatter.string(from: firstDate, to: lastDate),
            latestValue: InvoiceDecimal.money(from: latestValue),
            peakValue: InvoiceDecimal.money(from: peakValue),
            movementCount: selectedSeriesDates.count
        )
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

    private func dailyValues(for category: InvoiceCategory) -> [Double] {
        cachedAllDates.map { date in
            dailyTotal(on: date, category: category).doubleValue
        }
    }

    private func dailyBalanceValues() -> [Double] {
        cachedAllDates.map { date in
            let credit = dailyTotal(on: date, category: .credit)
            let debit = dailyTotal(on: date, category: .debit)
            return InvoiceDecimal.money(from: credit - debit).doubleValue
        }
    }

    private func dailyTotal(on date: Date, category: InvoiceCategory) -> Decimal {
        let total = chartData.groupedInvoices[date, default: []]
            .filter { $0.category == category }
            .reduce(Decimal.zero) { partialResult, invoice in
                partialResult + invoice.ivaDecimal
            }

        return InvoiceDecimal.money(from: total)
    }

    private func filteredSeries(
        dates: [Date],
        cumulative: [Double],
        daily: [Double],
        keepsZeroDailyValues: Bool
    ) -> (dates: [Date], cumulative: [Double], daily: [Double]) {
        let filtered = zip(dates.indices, dates).compactMap { index, date -> (Date, Double, Double)? in
            let cumulativeValue = InvoiceDecimal.money(from: cumulative[index]).doubleValue
            let dailyValue = InvoiceDecimal.money(from: daily[index]).doubleValue

            if !keepsZeroDailyValues, dailyValue == 0 {
                return nil
            }

            return (date, cumulativeValue, dailyValue)
        }

        return (
            dates: filtered.map(\.0),
            cumulative: filtered.map(\.1),
            daily: filtered.map(\.2)
        )
    }

    private static let periodFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.locale = Locale(identifier: "es_AR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
