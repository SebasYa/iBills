//
//  Graph.swift
//  iBills
//
//  Created by Sebastian Yanni on 05/08/2024.
//

import SwiftUI
import SwiftData
import Charts



struct GraphView: View {
    @Query private var invoices: [Invoice]
    @StateObject private var viewModel: GraphViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: GraphViewModel(invoices: []))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Botones de selección
                HStack {
                    Button(action: { viewModel.selectedChartType = .debit }) {
                        Text("Débito")
                            .padding()
                            .background(viewModel.selectedChartType == .debit ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: { viewModel.selectedChartType = .credit }) {
                        Text("Crédito")
                            .padding()
                            .background(viewModel.selectedChartType == .credit ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: { viewModel.selectedChartType = .difference }) {
                        Text("Diferencia")
                            .padding()
                            .background(viewModel.selectedChartType == .difference ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                ScrollView {
                    if viewModel.cachedAllDates.isEmpty {
                        Text("No hay datos disponibles")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        VStack {
                            switch viewModel.selectedChartType {
                            case .debit:
                                // Gráfico de IVA Débito
                                Section(header: Text("IVA Débito")) {
                                    if let selectedDebitIndex = viewModel.selectedDebitIndex {
                                        let selectedDate = viewModel.cachedAllDates[selectedDebitIndex]
                                        let selectedDebit = viewModel.cachedCumulativeDebit[selectedDebitIndex]
                                        VStack {
                                            Text("Fecha: \(selectedDate, formatter: dateFormatter)")
                                            Text("IVA Débito: \(selectedDebit, specifier: "%.2f")")
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(5)
                                        .shadow(radius: 5)
                                        .padding(.bottom, 5)
                                    }
                                    
                                    Chart {
                                        ForEach(0..<viewModel.cachedAllDates.count, id: \.self) { index in
                                            LineMark(
                                                x: .value("Fecha", viewModel.cachedAllDates[index], unit: .day),
                                                y: .value("IVA Débito", viewModel.cachedCumulativeDebit[index])
                                            )
                                            .foregroundStyle(Color.green)
                                            .symbol(Circle())
                                            .symbolSize(50)
                                            .interpolationMethod(.linear)
                                        }
                                        if let selectedDebitDate = viewModel.selectedDebitDate {
                                            RuleMark(x: .value("Selected Date", selectedDebitDate))
                                                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                                                .foregroundStyle(.red)
                                        }
                                    }
                                    .chartOverlay { proxy in
                                        GeometryReader { geometry in
                                            Rectangle().fill(Color.clear).contentShape(Rectangle())
                                                .gesture(
                                                    DragGesture(minimumDistance: 0)
                                                        .onChanged { value in
                                                            viewModel.handleDragGesture(value: value, proxy: proxy, geometry: geometry, currentSelectedDate: $viewModel.selectedDebitDate, currentSelectedIndex: $viewModel.selectedDebitIndex)
                                                        }
                                                        .onEnded { _ in
                                                            viewModel.selectedDebitDate = nil
                                                            viewModel.selectedDebitIndex = nil
                                                        }
                                                )
                                        }
                                    }
                                    .frame(height: 200)
                                }
                                
                            case .credit:
                                // Gráfico de IVA Crédito
                                Section(header: Text("IVA Crédito")) {
                                    if let selectedCreditIndex = viewModel.selectedCreditIndex {
                                        let selectedDate = viewModel.cachedAllDates[selectedCreditIndex]
                                        let selectedCredit = viewModel.cachedCumulativeCredit[selectedCreditIndex]
                                        VStack {
                                            Text("Fecha: \(selectedDate, formatter: dateFormatter)")
                                            Text("IVA Crédito: \(selectedCredit, specifier: "%.2f")")
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(5)
                                        .shadow(radius: 5)
                                        .padding(.bottom, 5)
                                    }
                                    
                                    Chart {
                                        ForEach(0..<viewModel.cachedAllDates.count, id: \.self) { index in
                                            LineMark(
                                                x: .value("Fecha", viewModel.cachedAllDates[index], unit: .day),
                                                y: .value("IVA Crédito", viewModel.cachedCumulativeCredit[index])
                                            )
                                            .foregroundStyle(Color.red)
                                            .symbol(Circle())
                                            .symbolSize(50)
                                            .interpolationMethod(.linear)
                                        }
                                        if let selectedCreditDate = viewModel.selectedCreditDate {
                                            RuleMark(x: .value("Selected Date", selectedCreditDate))
                                                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                                                .foregroundStyle(.red)
                                        }
                                    }
                                    .chartOverlay { proxy in
                                        GeometryReader { geometry in
                                            Rectangle().fill(Color.clear).contentShape(Rectangle())
                                                .gesture(
                                                    DragGesture(minimumDistance: 0)
                                                        .onChanged { value in
                                                            viewModel.handleDragGesture(value: value, proxy: proxy, geometry: geometry, currentSelectedDate: $viewModel.selectedCreditDate, currentSelectedIndex: $viewModel.selectedCreditIndex)
                                                        }
                                                        .onEnded { _ in
                                                            viewModel.selectedCreditDate = nil
                                                            viewModel.selectedCreditIndex = nil
                                                        }
                                                )
                                        }
                                    }
                                    .frame(height: 200)
                                }
                                
                            case .difference:
                                // Gráfico de IVA Promedio
                                Section(header: Text("Balance IVA")) {
                                    if let selectedAverageIndex = viewModel.selectedAverageIndex {
                                        let selectedDate = viewModel.cachedAllDates[selectedAverageIndex]
                                        let selectedAverage = viewModel.cachedDailyAverage[selectedAverageIndex]
                                        VStack {
                                            Text("Fecha: \(selectedDate, formatter: dateFormatter)")
                                            Text("Saldo IVA: \(selectedAverage, specifier: "%.2f")")
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(5)
                                        .shadow(radius: 5)
                                        .padding(.bottom, 5)
                                    }
                                    
                                    Chart {
                                        ForEach(0..<viewModel.cachedAllDates.count, id: \.self) { index in
                                            LineMark(
                                                x: .value("Fecha", viewModel.cachedAllDates[index], unit: .day),
                                                y: .value("Balance", viewModel.cachedDailyAverage[index])
                                            )
                                            .foregroundStyle(viewModel.cachedDailyAverage[index] >= 0 ? .green : .red)
                                            .symbol(Circle())
                                            .symbolSize(50)
                                            .interpolationMethod(.linear)
                                        }
                                        if let selectedAverageDate = viewModel.selectedAverageDate {
                                            RuleMark(x: .value("Selected Date", selectedAverageDate))
                                                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                                                .foregroundStyle(.red)
                                        }
                                    }
                                    .chartOverlay { proxy in
                                        GeometryReader { geometry in
                                            Rectangle().fill(Color.clear).contentShape(Rectangle())
                                                .gesture(
                                                    DragGesture(minimumDistance: 0)
                                                        .onChanged { value in
                                                            viewModel.handleDragGesture(value: value, proxy: proxy, geometry: geometry, currentSelectedDate: $viewModel.selectedAverageDate, currentSelectedIndex: $viewModel.selectedAverageIndex)
                                                        }
                                                        .onEnded { _ in
                                                            viewModel.selectedAverageDate = nil
                                                            viewModel.selectedAverageIndex = nil
                                                        }
                                                )
                                        }
                                    }
                                    .frame(height: 200)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Gráficos de IVA")
            .onAppear {
                viewModel.updateInvoices(invoices: invoices)
            }
        }
    }
}
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

#Preview {
    GraphView()
}
