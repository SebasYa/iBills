//
//  GraphViewModel.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI
import Charts

class GraphViewModel: ObservableObject {
    @Published var invoices: [Invoice] {
        didSet {
            groupInvoicesByYear()
        }
    }
    
    @Published var selectedChartType: ChartType = .credit
    @Published var selectedYear: String = Calendar.current.component(.year, from: Date()).description
    
    @Published var selectedDebitDate: Date? = nil
    @Published var selectedCreditDate: Date? = nil
    @Published var selectedAverageDate: Date? = nil
    
    @Published var selectedDebitIndex: Int? = nil
    @Published var selectedCreditIndex: Int? = nil
    @Published var selectedAverageIndex: Int? = nil
    
    @Published var availableYears: [String] = []
    
    @Published var cachedGroupedInvoices: [Date: [Invoice]] = [:]
    @Published var cachedAllDates: [Date] = []
    @Published var cachedCumulativeDebit: [Double] = []
    @Published var cachedCumulativeCredit: [Double] = []
    @Published var cachedDailyAverage: [Double] = []
    
    init(invoices: [Invoice] = []) {
        self.invoices = invoices
        groupInvoicesByYear()
    }
    
    // Groups invoices by year and updates available years
    private func groupInvoicesByYear() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        
        let groupedByYear = Dictionary(grouping: invoices) { invoice in
            dateFormatter.string(from: invoice.date)
        }
        
        availableYears = groupedByYear.keys.sorted(by: { $0 < $1 })
        
        if !availableYears.isEmpty, selectedYear.isEmpty {
            selectedYear = availableYears.first!
        }
        
        cacheData(for: selectedYear)
    }
    
    // Updates invoices and re-caches data
    func updateInvoices(invoices: [Invoice]) {
        self.invoices = invoices
    }
    
    // Caches data for the selected year, including grouped invoices and calculated values
    func cacheData(for year: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        
        // Group invoices by date
        let invoicesForYear = invoices.filter({ dateFormatter.string(from: $0.date) == year })
        
        let calendar = Calendar.current
        
        // Sort all dates
        cachedGroupedInvoices = Dictionary(grouping: invoicesForYear) { invoice in
            calendar.startOfDay(for: invoice.date)
        }
        
        // Ordenar todas las fechas
        cachedAllDates = cachedGroupedInvoices.keys.sorted()
        
        // Calculate cumulative values for Credit and Debit
        cachedCumulativeDebit = cachedAllDates.map { date in
            cachedGroupedInvoices[date]?.filter { $0.isCredit }.reduce(0) { $0 + $1.iva } ?? 0
        }.reduce(into: []) { result, value in
            let cumulativeValue = (result.last ?? 0) + value
            result.append(cumulativeValue)
        }
        
        cachedCumulativeCredit = cachedAllDates.map { date in
            cachedGroupedInvoices[date]?.filter { !$0.isCredit }.reduce(0) { $0 + $1.iva } ?? 0
        }.reduce(into: []) { result, value in
            let cumulativeValue = (result.last ?? 0) + value
            result.append(cumulativeValue)
        }
        
        // Calculate daily average (difference between Credit and Debit)
        cachedDailyAverage = zip(cachedCumulativeCredit, cachedCumulativeDebit).map { $0 - $1 }
    }
    
    // Determines the selected date based on x position in the chart
    func selectedDate(for xPosition: CGFloat, proxy: ChartProxy?, geometry: GeometryProxy?) -> Date {
        guard let proxy = proxy, let geometry = geometry else { return Date() }
        let chartXPosition = xPosition - geometry.frame(in: .local).origin.x
        return proxy.value(atX: chartXPosition) ?? Date()
    }

    // Handles drag gestures for updating chart indicators
    func handleDragGesture(value: DragGesture.Value, proxy: ChartProxy, geometry: GeometryProxy, currentSelectedDate: Binding<Date?>, currentSelectedIndex: Binding<Int?>, lastDate: Binding<Date?>) {
        let location = value.location
        let chartXPosition = location.x - geometry.frame(in: .local).origin.x
        
        // Get the date corresponding to the current drag gesture position
        let date = selectedDate(for: chartXPosition, proxy: proxy, geometry: geometry)
        
        // Normalize the date to the start of the day for comparison
        let calendar = Calendar.current
        let roundedDate = calendar.startOfDay(for: date)
        
        // Update the position of the RuleMark independently
        currentSelectedDate.wrappedValue = date
        
        // Only update index and values if the date changes to a new day
        if let lastSelectedDate = lastDate.wrappedValue {
            let roundedLastDate = calendar.startOfDay(for: lastSelectedDate)
            if roundedDate != roundedLastDate {
                currentSelectedIndex.wrappedValue = findClosestIndex(for: roundedDate, in: cachedAllDates)
                lastDate.wrappedValue = roundedDate
            }
        } else {
            currentSelectedIndex.wrappedValue = findClosestIndex(for: roundedDate, in: cachedAllDates)
            lastDate.wrappedValue = roundedDate
        }
    }
    
    func selectedDate(for xPosition: CGFloat, proxy: ChartProxy, geometry: GeometryProxy) -> Date {
        let chartXPosition = xPosition - geometry.frame(in: .local).origin.x
        return proxy.value(atX: chartXPosition) ?? Date()
    }
    
    // Finds the closest index for a given date in a list of dates
    func findClosestIndex(for date: Date, in dates: [Date]) -> Int? {
        // Encuentra el índice del día más cercano
        return dates.enumerated().min(by: { abs($0.element.timeIntervalSince(date)) < abs($1.element.timeIntervalSince(date)) })?.offset
    }
}
