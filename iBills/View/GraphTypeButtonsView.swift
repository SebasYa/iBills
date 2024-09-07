//
//  GraphTypeButtonsView.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI

struct GraphTypeButtonsView: View {
    @ObservedObject var viewModel: GraphViewModel
    @Namespace private var animation
    @State private var buttonLocation: CGRect = .zero
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(ChartType.allCases, id: \.self) { chartType in
                Button(action: {
                    viewModel.selectedChartType = chartType
                }) {
                    HStack(spacing: 5) {
                        Text(chartType.title)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background {
                                if viewModel.selectedChartType == chartType {
                                    Capsule()
                                        .fill(Color.blue.gradient)
                                        .matchedGeometryEffect(id: "SELECTED_TAB", in: animation)
                                } else {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.2))
                                }
                            }
                            .foregroundStyle(viewModel.selectedChartType == chartType ? .white : .primary)
                            .onGeometryChange(for: CGRect.self, of: {
                                $0.frame(in: .named("BUTTONS_VIEW"))
                            }, action: { newValue in
                                if viewModel.selectedChartType == chartType {
                                    buttonLocation = newValue
                                }
                            })
                    }
                    .buttonStyle(.plain)
                    .animation(.smooth(duration: 0.3, extraBounce: 0), value: viewModel.selectedChartType)
                }
            }
        }
        .coordinateSpace(.named("BUTTONS_VIEW"))
        .padding()
    }
}

#Preview {
    GraphTypeButtonsView(viewModel: GraphViewModel())
}
