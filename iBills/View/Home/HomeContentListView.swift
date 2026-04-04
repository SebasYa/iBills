//
//  HomeContentListView.swift
//  iBills
//
//  Created by Sebastian Yanni on 03/04/2026.
//

import SwiftUI

struct HomeContentListView: View {
    let isSearching: Bool
    let visibleSections: [InvoiceYearSection]
    let isDeleteMode: Bool
    let yearBinding: (InvoiceYearSection) -> Binding<Bool>
    let monthBinding: (InvoiceMonthSection) -> Binding<Bool>
    let onAddInvoice: () -> Void
    let onDeleteYear: (InvoiceYearSection) -> Void
    let onDeleteMonth: (InvoiceMonthSection) -> Void
    let onDeleteInvoice: (Invoice) -> Void

    var body: some View {
        List {
            Section {
                HomeAddInvoiceButton(action: onAddInvoice)
            }
            .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 6, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            if visibleSections.isEmpty {
                HomeEmptyStateCard(isSearching: isSearching)
                    .listRowInsets(EdgeInsets(top: 24, leading: 16, bottom: 16, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(visibleSections) { yearSection in
                    HomeYearSectionView(
                        yearSection: yearSection,
                        isDeleteMode: isDeleteMode,
                        isExpanded: yearBinding(yearSection),
                        monthBinding: monthBinding,
                        onDeleteYear: {
                            onDeleteYear(yearSection)
                        },
                        onDeleteMonth: onDeleteMonth,
                        onDeleteInvoice: onDeleteInvoice
                    )
                }
            }

            Section {
                ScrollBottomSpacer()
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .safeAreaPadding(.top, 8)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }
}

#Preview {
    HomeContentListView(
        isSearching: false,
        visibleSections: PreviewFixtures.homeSections(),
        isDeleteMode: false,
        yearBinding: { _ in .constant(true) },
        monthBinding: { _ in .constant(true) },
        onAddInvoice: {},
        onDeleteYear: { _ in },
        onDeleteMonth: { _ in },
        onDeleteInvoice: { _ in }
    )
}
