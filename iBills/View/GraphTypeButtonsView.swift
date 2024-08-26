//
//  GraphTypeButtonsView.swift
//  iBills
//
//  Created by Sebastian Yanni on 22/08/2024.
//

import SwiftUI

struct GraphTypeButtonsView: View {
    @ObservedObject var viewModel: GraphViewModel
    
    var body: some View {
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
    }
}

#Preview {
    GraphTypeButtonsView(viewModel: GraphViewModel())
}
