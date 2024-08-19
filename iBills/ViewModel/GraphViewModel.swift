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
            cacheData()
        }
    }
    
    @Published var selectedChartType: ChartType = .debit
    
    @Published var selectedDebitDate: Date? = nil
    @Published var selectedCreditDate: Date? = nil
    @Published var selectedAverageDate: Date? = nil
    
    @Published var selectedDebitIndex: Int? = nil
    @Published var selectedCreditIndex: Int? = nil
    @Published var selectedAverageIndex: Int? = nil
    
    @Published var cachedGroupedInvoices: [Date: [Invoice]] = [:]
    @Published var cachedAllDates: [Date] = []
    @Published var cachedCumulativeDebit: [Double] = []
    @Published var cachedCumulativeCredit: [Double] = []
    @Published var cachedDailyAverage: [Double] = []
    
    init(invoices: [Invoice] = []) {
        self.invoices = invoices
        cacheData()
    }
    
    func updateInvoices(invoices: [Invoice]) {
        self.invoices = invoices
    }
    
    func cacheData() {
        let calendar = Calendar.current
        
        // Agrupar las facturas por fecha
        cachedGroupedInvoices = Dictionary(grouping: invoices) { invoice in
            calendar.startOfDay(for: invoice.date)
        }
        
        // Ordenar todas las fechas involucradas (débito y crédito)
        cachedAllDates = cachedGroupedInvoices.keys.sorted()
        
        // Calcular los valores acumulativos de IVA Débito
        cachedCumulativeDebit = cachedAllDates.map { date in
            cachedGroupedInvoices[date]?.filter { $0.isDebit }.reduce(0) { $0 + $1.iva } ?? 0
        }.reduce(into: []) { result, value in
            result.append((result.last ?? 0) + value)
        }
        
        // Calcular los valores acumulativos de IVA Crédito
        cachedCumulativeCredit = cachedAllDates.map { date in
            cachedGroupedInvoices[date]?.filter { !$0.isDebit }.reduce(0) { $0 + $1.iva } ?? 0
        }.reduce(into: []) { result, value in
            result.append((result.last ?? 0) + value)
        }
        
        // Calcular el promedio de IVA diario (diferencia entre débito y crédito para cada día)
        cachedDailyAverage = zip(cachedCumulativeDebit, cachedCumulativeCredit).map { $0 - $1 }
    }
    
    func selectedDate(for xPosition: CGFloat, proxy: ChartProxy?, geometry: GeometryProxy?) -> Date {
        guard let proxy = proxy, let geometry = geometry else { return Date() }
        let chartXPosition = xPosition - geometry.frame(in: .local).origin.x
        return proxy.value(atX: chartXPosition) ?? Date()
    }
    
    func handleDragGesture(value: DragGesture.Value, proxy: ChartProxy, geometry: GeometryProxy, currentSelectedDate: Binding<Date?>, currentSelectedIndex: Binding<Int?>) {
        let location = value.location
        let chartXPosition = location.x - geometry.frame(in: .local).origin.x
        let date = selectedDate(for: chartXPosition, proxy: proxy, geometry: geometry)
        currentSelectedDate.wrappedValue = date
        currentSelectedIndex.wrappedValue = findClosestIndex(for: date, in: cachedAllDates)
    }
    
    func findClosestIndex(for date: Date, in dates: [Date]) -> Int? {
        return dates.enumerated().min(by: { abs($0.element.timeIntervalSince(date)) < abs($1.element.timeIntervalSince(date)) })?.offset
    }
}
