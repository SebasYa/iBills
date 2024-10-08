//
//  YearPickerView.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI

struct YearPickerView: View {
    @ObservedObject var viewModel: GraphViewModel
    @Namespace private var animation
    
    var body: some View {
        if !viewModel.invoices.isEmpty {
            HStack(spacing: 10) {
                
                ForEach(viewModel.availableYears, id: \.self) { year in
                    
                    Button {
                        viewModel.selectedYear = year
                        viewModel.cacheData(for: year)
                    } label: {
                        Text(year)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background {
                                if viewModel.selectedYear == year {
                                    Capsule()
                                        .fill(Color.blue.gradient)
                                        .matchedGeometryEffect(id: "SELECTED_YEAR", in: animation)
                                } else {
                                    Capsule()
                                        .fill(Color.clear)
                                }
                            }
                            .foregroundStyle(viewModel.selectedYear == year ? .white : .gray.opacity(0.9))
                    }
                    .buttonStyle(.plain)
                    .animation(.smooth(duration: 0.3, extraBounce: 0), value: viewModel.selectedYear)
                }
            }
            .coordinateSpace(.named("TABBARVIEW"))
            .padding(.horizontal, 5)
            .frame(height: 45)
            .background(
                .background
                    .opacity(0.4)
                    .shadow(.drop(color: .black.opacity(0.08), radius: 5, x: 5, y: 5))
                    .shadow(.drop(color: .black.opacity(0.06), radius: 5, x: -5, y: -5)),
                in: .capsule
            )
            .zIndex(50)
            .animation(.smooth(duration: 0.3, extraBounce: 0), value: viewModel.selectedYear)
        } else {
            Text("Ingrese facturas para generar gráficos")
                .font(.title3)
                .foregroundStyle(.gray)
                .padding()
        }
    }
}

#Preview {
    GraphView()
}
