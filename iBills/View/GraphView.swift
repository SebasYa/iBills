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
    @Query(sort: \Invoice.date, order: .reverse) private var invoices: [Invoice]
    @StateObject private var viewModel: GraphViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: GraphViewModel(invoices: []))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.5), Color.brown.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        YearPickerView(viewModel: viewModel)

                        GraphTypeButtonsView(viewModel: viewModel)

                        if viewModel.cachedAllDates.isEmpty {
                            Text("No hay datos disponibles")
                                .foregroundColor(.gray)
                                .padding()
                        } else if viewModel.selectedSeriesDates.isEmpty {
                            Text("No hay movimientos para \(viewModel.selectedSeriesTitle.lowercased()) en \(viewModel.selectedYear).")
                                .foregroundStyle(.white.opacity(0.75))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(Color.black.opacity(0.16))
                                )
                        } else {
                            switch viewModel.selectedChartType {
                            case .credit:
                                GraphSectionView(
                                    selectedDate: $viewModel.selectedCreditDate,
                                    selectedIndex: $viewModel.selectedCreditIndex,
                                    title: "IVA Crédito",
                                    data: viewModel.selectedSeriesData,
                                    detailData: viewModel.selectedDailySeriesData,
                                    detailLabel: viewModel.selectedSeriesDetailTitle,
                                    dates: viewModel.selectedSeriesDates,
                                    color: Color.green,
                                    domain: viewModel.chartDomain
                                )
                            case .balance:
                                GraphSectionView(
                                    selectedDate: $viewModel.selectedBalanceDate,
                                    selectedIndex: $viewModel.selectedBalanceIndex,
                                    title: "Balance IVA",
                                    data: viewModel.selectedSeriesData,
                                    detailData: viewModel.selectedDailySeriesData,
                                    detailLabel: viewModel.selectedSeriesDetailTitle,
                                    dates: viewModel.selectedSeriesDates,
                                    color: Color.indigo,
                                    domain: viewModel.chartDomain
                                )
                            case .debit:
                                GraphSectionView(
                                    selectedDate: $viewModel.selectedDebitDate,
                                    selectedIndex: $viewModel.selectedDebitIndex,
                                    title: "IVA Débito",
                                    data: viewModel.selectedSeriesData,
                                    detailData: viewModel.selectedDailySeriesData,
                                    detailLabel: viewModel.selectedSeriesDetailTitle,
                                    dates: viewModel.selectedSeriesDates,
                                    color: Color.red,
                                    domain: viewModel.chartDomain
                                )
                            }

                            if let overview = viewModel.overview {
                                GraphOverviewCard(
                                    overview: overview,
                                    color: viewModel.selectedSeriesColor
                                )
                            }
                        }

                        ScrollBottomSpacer()
                    }
                    .padding(16)
                }
                .safeAreaPadding(.top, 8)
                .navigationTitle("Gráficos de IVA")
                .scrollIndicators(.hidden)
                .onAppear {
                    viewModel.updateInvoices(invoices: invoices)
                }
                .onChange(of: invoices.count) { _, _ in
                    viewModel.updateInvoices(invoices: invoices)
                }
            }
        }
    }
}

#Preview {
    GraphView()
}
