//
//  AddBillView.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI
import SwiftData

struct AddInvoiceView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = AddInvoiceViewModel()
    @FocusState private var formIsFocused: Bool
    @FocusState private var focusedInput: CreateInvoiceModel?

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [ Color.brown.opacity(0.2), Color.brown]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                Form {
                    TextField("Razón Social", text: $viewModel.razonSocial)
                        .keyboardType(.asciiCapable)
                        .focused($formIsFocused)
                        .focused($focusedInput, equals: .razonSocial)

                    TextField("Numero de Factura", text: $viewModel.numeroFactura)
                        .keyboardType(.numberPad)
                        .focused($formIsFocused)
                        .focused($focusedInput, equals: .numeroDeFacturas)

                    TextField("Monto Total", text: $viewModel.amount)
                        .keyboardType(.decimalPad)
                        .focused($formIsFocused)
                        .focused($focusedInput, equals: .montoTotal)


                    DatePicker("Fecha", selection: $viewModel.selectedDate, displayedComponents: .date)

                    Picker("Porcentaje de IVA", selection: $viewModel.selectedVAT) {
                        Text("27%").tag(27.0)
                        Text("21%").tag(21.0)
                        Text("10,5%").tag(10.5)
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Toggle(isOn: Binding(
                        get: { viewModel.isCreditSelection },
                        set: { viewModel.isCreditSelection = $0 }
                    )) {
                        Text(viewModel.categoryTitle)
                    }
                    .foregroundStyle(viewModel.isCreditSelection ? Color.green : Color.red)


                    Button(action: {
                        viewModel.addInvoice()
                    }) {
                        Label("Agregar Factura", systemImage: "folder.fill.badge.plus")
                    }
                }
                .listRowBackground(Color.clear)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .navigationTitle("Agregar Factura")
                .toolbar {

                    ToolbarItemGroup(placement: .keyboard) {
                        Button("Done"){
                            formIsFocused = false
                        }
                        Spacer()

                        Button {
                            focusedInput = (focusedInput ?? .razonSocial).previous
                        } label: {
                            Image(systemName: "chevron.up")
                        }

                        Button {
                            focusedInput = (focusedInput ?? .razonSocial).next
                        } label: {
                            Image(systemName: "chevron.down")
                        }
                    }

                }
                // Show an alert if there is an error or success when adding the invoice
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(
                        title: Text(viewModel.showErrorAlert ? "Error" : "Factura Agregada"),
                        message: Text(viewModel.showErrorAlert ?
                                      viewModel.errorMessage ?? "Ocurrió un error inesperado." :
                                        viewModel.successMessage ?? "La factura se agregó exitosamente."),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .onAppear {
                    viewModel.setContext(context)
                    focusedInput = .razonSocial
                }
            }
        }
    }

}



#Preview {
    let container = try! ModelContainer(for: Invoice.self)
    return AddInvoiceView()
        .modelContainer(container)
}
