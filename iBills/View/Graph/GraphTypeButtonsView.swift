//
//  GraphTypeButtonsView.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI

struct GraphTypeButtonsView: View {
    @ObservedObject var viewModel: GraphViewModel
    
    var body: some View {
        Picker("Serie", selection: $viewModel.selectedChartType) {
            ForEach(ChartType.allCases, id: \.self) { chartType in
                Text(chartType.title)
                    .tag(chartType)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 2)
    }
}

#Preview {
    ZStack {
        Color.green.opacity(0.15)
            .ignoresSafeArea()
        GraphTypeButtonsView(viewModel: GraphViewModel())
            .padding()
    }
}
