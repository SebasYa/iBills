//
//  AddReceiptView.swift
//  iBills
//
//  Created by Sebastian Yanni on 05/08/2024.
//

import SwiftUI
import SwiftData

struct AddReceiptView: View {
    @Environment(\.modelContext) private var context
    @State private var explanation = ""
    @State private var date = Date()
    @State private var alarmSet = false
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Descripción", text: $explanation)
                    .keyboardType(.default)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            HStack {
                                Spacer()
                                Button("Done") {
                                    hideKeyboard()
                                }
                            }
                        }
                    }
                DatePicker("Fecha", selection: $date, displayedComponents: .date)
                Toggle("Alarma Seteada", isOn: $alarmSet)
                
                Button("Agregar Remito") {
                    // Crear la factura con un nuevo ID automáticamente generado
                    let receipt = Receipt(explanation: explanation, date: date, alarmSet: alarmSet)
                    // Insertar la factura en el contexto
                    context.insert(receipt)
                    // Guardar el contexto
                    try? context.save()
                    
                    // Limpiar los campos después de agregar la factura
                    self.explanation = ""
                    
                }
            }
            .navigationTitle("Agregar Remito")
            
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    AddReceiptView()
}
