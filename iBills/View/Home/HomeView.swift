//
//  Home.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Invoice.date, order: .reverse) private var invoices: [Invoice]

    @StateObject private var viewModel = HomeViewModel()
    @State private var isSearchPresented = false
    @State private var expandedYears: Set<String> = []
    @State private var expandedMonths: Set<String> = []

    private var visibleSections: [InvoiceYearSection] {
        viewModel.homeSections(from: invoices)
    }

    private var allSections: [InvoiceYearSection] {
        viewModel.allHomeSections(from: invoices)
    }

    private var allYearIDs: [String] {
        allSections.map(\.id)
    }

    private var allMonthIDs: [String] {
        allSections.flatMap { $0.months.map(\.id) }
    }

    private var isSearching: Bool {
        !viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var shouldShowSearchField: Bool {
        isSearchPresented || isSearching
    }

    private var isShowingDeleteConfirmation: Binding<Bool> {
        Binding(
            get: { viewModel.deleteTarget != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.clearDeleteTarget()
                }
            }
        )
    }

    init() {
        _invoices = Query(sort: \Invoice.date, order: .reverse)
    }

    @ViewBuilder
    var body: some View {
        if shouldShowSearchField {
            homeContent
                .searchable(
                    text: $viewModel.searchText,
                    isPresented: $isSearchPresented,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: "Razón social o número de factura",
                )
        } else {
            homeContent
        }
    }

    private var homeContent: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.brown, Color.brown.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                HomeContentListView(
                    isSearching: isSearching,
                    visibleSections: visibleSections,
                    isDeleteMode: viewModel.isDeleteYearMode,
                    yearBinding: { yearSection in
                        bindingForYear(yearSection.id)
                    },
                    monthBinding: { monthSection in
                        bindingForMonth(monthSection.id)
                    },
                    onAddInvoice: {
                        viewModel.showAddBill = true
                        viewModel.isDeleteYearMode = false
                    },
                    onDeleteYear: { yearSection in
                        viewModel.requestDeleteYear(yearSection.year)
                    },
                    onDeleteMonth: { monthSection in
                        viewModel.requestDeleteMonth(
                            year: monthSection.year,
                            month: monthSection.month,
                            title: monthSection.title
                        )
                    },
                    onDeleteInvoice: { invoice in
                        viewModel.requestDeleteInvoice(invoice)
                    }
                )
            }
            .navigationTitle("Facturas")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        if isSearchPresented {
                            viewModel.searchText = ""
                            isSearchPresented = false
                        } else {
                            viewModel.isDeleteYearMode = false
                            isSearchPresented = true
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }

                    Button {
                        if isSearchPresented || !viewModel.searchText.isEmpty {
                            viewModel.searchText = ""
                            isSearchPresented = false
                        }

                        withAnimation(.snappy) {
                            viewModel.isDeleteYearMode.toggle()
                        }
                    } label: {
                        Image(systemName: viewModel.isDeleteYearMode ? "checkmark.circle.fill" : "trash")
                    }
                }
            }
            .onChange(of: viewModel.searchText) { _, newValue in
                if !newValue.isEmpty {
                    viewModel.isDeleteYearMode = false
                }
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Ocurrió un error inesperado.")
            }
            .confirmationDialog(
                viewModel.deleteTarget?.title ?? "Eliminar facturas",
                isPresented: isShowingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                if let deleteTarget = viewModel.deleteTarget {
                    Button(deleteTarget.buttonTitle, role: .destructive) {
                        viewModel.confirmDeletion(from: invoices)
                    }
                }

                Button("Cancelar", role: .cancel) {}
            } message: {
                Text(viewModel.deleteTarget?.message ?? "Esta acción no se puede deshacer.")
            }
            .sheet(isPresented: $viewModel.showAddBill) {
                AddInvoiceView()
                    .environment(\.modelContext, context)
            }
            .onAppear {
                viewModel.setContext(context)
                syncExpandedState()
            }
            .onChange(of: allYearIDs) { _, _ in
                syncExpandedState()
            }
            .onChange(of: allMonthIDs) { _, _ in
                syncExpandedState()
            }
        }
    }

    private func bindingForYear(_ year: String) -> Binding<Bool> {
        Binding {
            isSearching || expandedYears.contains(year)
        } set: { isExpanded in
            if isExpanded {
                expandedYears.insert(year)
            } else {
                expandedYears.remove(year)
            }
        }
    }

    private func bindingForMonth(_ monthID: String) -> Binding<Bool> {
        Binding {
            isSearching || expandedMonths.contains(monthID)
        } set: { isExpanded in
            if isExpanded {
                expandedMonths.insert(monthID)
            } else {
                expandedMonths.remove(monthID)
            }
        }
    }

    private func syncExpandedState() {
        let currentYearIDs = Set(allYearIDs)
        expandedYears.formIntersection(currentYearIDs)

        let currentMonthIDs = Set(allMonthIDs)
        expandedMonths.formIntersection(currentMonthIDs)
    }
}

#Preview {
    HomeView()
}
