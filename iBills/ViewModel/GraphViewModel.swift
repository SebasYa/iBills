//
//  GraphViewModel.swift
//  iBills
//
//  Created by Sebastian Yanni on 18/08/2024.
//

import SwiftUI
import Charts

class GraphViewModel: ObservableObject {
    @Published var invoices: [Invoice] {
        didSet {
            groupInvoicesByYear()
        }
    }
    
    @Published var selectedChartType: ChartType = .debit
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
//        cacheData()
        groupInvoicesByYear()
    }
    
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
    
    func updateInvoices(invoices: [Invoice]) {
        self.invoices = invoices
    }
    
    func cacheData(for year: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        
        // Filtrar facturas por año
        let invoicesForYear = invoices.filter({ dateFormatter.string(from: $0.date) == year })
        
        let calendar = Calendar.current
        
        // Agrupar facturas por fecha
        cachedGroupedInvoices = Dictionary(grouping: invoicesForYear) { invoice in
            calendar.startOfDay(for: invoice.date)
        }
        
        // Ordenar todas las fechas
        cachedAllDates = cachedGroupedInvoices.keys.sorted()
        
        // Calcular valores acumulados para Débito y Crédito
        cachedCumulativeDebit = cachedAllDates.map { date in
            cachedGroupedInvoices[date]?.filter { $0.isDebit }.reduce(0) { $0 + $1.iva } ?? 0
        }.reduce(into: []) { result, value in
            let cumulativeValue = (result.last ?? 0) + value
            result.append(cumulativeValue)
        }
        
        cachedCumulativeCredit = cachedAllDates.map { date in
            cachedGroupedInvoices[date]?.filter { !$0.isDebit }.reduce(0) { $0 + $1.iva } ?? 0
        }.reduce(into: []) { result, value in
            let cumulativeValue = (result.last ?? 0) + value
            result.append(cumulativeValue)
        }
        
        // Calcular el promedio diario (diferencia entre Débito y Crédito)
        cachedDailyAverage = zip(cachedCumulativeDebit, cachedCumulativeCredit).map { $0 - $1 }
    }
    
    func selectedDate(for xPosition: CGFloat, proxy: ChartProxy?, geometry: GeometryProxy?) -> Date {
        guard let proxy = proxy, let geometry = geometry else { return Date() }
        let chartXPosition = xPosition - geometry.frame(in: .local).origin.x
        return proxy.value(atX: chartXPosition) ?? Date()
    }
    
    func handleDragGesture(value: DragGesture.Value, proxy: ChartProxy, geometry: GeometryProxy, currentSelectedDate: Binding<Date?>, currentSelectedIndex: Binding<Int?>, lastDate: Binding<Date?>) {
        let location = value.location
        let chartXPosition = location.x - geometry.frame(in: .local).origin.x
        
        // Obtén la fecha correspondiente a la posición actual del gesto
        let date = selectedDate(for: chartXPosition, proxy: proxy, geometry: geometry)
        
        // Redondea la fecha al inicio del día para la comparación
        let calendar = Calendar.current
        let roundedDate = calendar.startOfDay(for: date)
        
        // Actualiza la posición del RuleMark independientemente
        currentSelectedDate.wrappedValue = date
        
        // Solo actualiza el índice y valores mostrados si la fecha cambia a un nuevo día
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
    
    func findClosestIndex(for date: Date, in dates: [Date]) -> Int? {
        // Encuentra el índice del día más cercano
        return dates.enumerated().min(by: { abs($0.element.timeIntervalSince(date)) < abs($1.element.timeIntervalSince(date)) })?.offset
    }
}
