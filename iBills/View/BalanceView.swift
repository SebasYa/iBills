//
//  BalanceView.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI
import SwiftData

struct BalanceView: View {
    @Query(sort: \Invoice.date, order: .reverse) private var invoices: [Invoice]
    @StateObject private var viewModel = BalanceViewModel()
    @State private var selectedYear = ""

    private var availableYears: [String] {
        viewModel.availableYears(from: invoices)
    }

    private var displayedYear: String {
        viewModel.defaultSelectedYear(
            from: invoices,
            preferredYear: selectedYear.isEmpty ? nil : selectedYear
        )
    }

    private var displayedYearBinding: Binding<String> {
        Binding(
            get: { displayedYear },
            set: { selectedYear = $0 }
        )
    }

    private var selectedYearInvoices: [Invoice] {
        viewModel.invoices(for: displayedYear, from: invoices)
    }

    private var summary: VATBalanceSummary {
        viewModel.summary(for: selectedYearInvoices)
    }

    private var insights: BalanceInsights {
        viewModel.insights(for: selectedYearInvoices, summary: summary)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.35), Color.brown.opacity(0.82)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        if availableYears.isEmpty {
                            BalanceEmptyStateCard()
                        } else {
                            HomeBalanceSummaryCard(
                                years: availableYears,
                                selectedYear: displayedYearBinding,
                                invoiceCount: selectedYearInvoices.count,
                                summary: summary
                            )

                            BalanceInsightsSection(insights: insights)
                        }

                        ScrollBottomSpacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
                .safeAreaPadding(.top, 8)
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Balance de IVA")
            .safeAreaPadding(.bottom, 5)
        }
    }
}

#Preview {
    BalanceView()
}
