//
//  Graph.swift
//  iBills
//
//  Created by Sebastian Yanni.
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
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.5), Color.brown.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                VStack {
                    
                    YearPickerView(viewModel: viewModel)
                    
                    GraphTypeButtonsView(viewModel: viewModel)
                    
                    ScrollView {
                        // Display a message if no data is available
                        if viewModel.cachedAllDates.isEmpty {
                            Text("No hay datos disponibles")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            // Stack to display different graph sections based on the selected chart type
                            VStack {
                                switch viewModel.selectedChartType {
                                    
                                case .credit:
                                    GraphSectionView(
                                        selectedDate: $viewModel.selectedCreditDate,
                                        selectedIndex: $viewModel.selectedCreditIndex,
                                        title: "IVA Crédito",
                                        data: viewModel.cachedCumulativeCredit,
                                        dates: viewModel.cachedAllDates,
                                        color: Color.green,
                                        viewModel: viewModel
                                    )

                                    
                                case .difference:
                                    GraphSectionView(
                                        selectedDate: $viewModel.selectedAverageDate,
                                        selectedIndex: $viewModel.selectedAverageIndex,
                                        title: "Balance IVA",
                                        data: viewModel.cachedDailyAverage,
                                        dates: viewModel.cachedAllDates,
                                        color: Color.indigo,
                                        viewModel: viewModel
                                    )
                                
                                    
                                case .debit:
                                    GraphSectionView(
                                        selectedDate: $viewModel.selectedDebitDate,
                                        selectedIndex: $viewModel.selectedDebitIndex,
                                        title: "IVA Débito",
                                        data: viewModel.cachedCumulativeDebit,
                                        dates: viewModel.cachedAllDates,
                                        color: Color.red,
                                        viewModel: viewModel
                                    )
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
}

#Preview {
    GraphView()
}
