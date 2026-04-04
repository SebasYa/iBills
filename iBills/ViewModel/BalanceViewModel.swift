//
//  BalanceViewModel.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI

final class BalanceViewModel: ObservableObject {
    private let analyticsService: InvoiceAnalyticsProviding

    init(analyticsService: InvoiceAnalyticsProviding = InvoiceAnalyticsService()) {
        self.analyticsService = analyticsService
    }

    func groupedInvoices(byYearFrom invoices: [Invoice]) -> [String: [Invoice]] {
        analyticsService.groupInvoicesByYear(invoices)
    }

    func availableYears(from invoices: [Invoice]) -> [String] {
        analyticsService.availableYears(invoices: invoices)
    }

    func defaultSelectedYear(from invoices: [Invoice], preferredYear: String) -> String {
        analyticsService.defaultSelectedYear(from: invoices, preferredYear: preferredYear) ?? ""
    }

    func summary(for invoices: [Invoice]) -> VATBalanceSummary {
        analyticsService.makeBalanceSummary(for: invoices)
    }
}
