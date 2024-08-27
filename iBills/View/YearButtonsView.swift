//
//  YearButtonsView.swift
//  iBills
//
//  Created by Sebastian Yanni on 27/08/2024.
//

import SwiftUI

struct YearButtonsView: View {
    let years: [String]
    @Binding var selectedYear: String
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 10) {
            ForEach(years, id: \.self) { year in
                Button(action: {
                    selectedYear = year
                }) {
                    Text(year)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background {
                            if selectedYear == year {
                                Capsule()
                                    .fill(Color.blue.gradient)
                                    .matchedGeometryEffect(id: "SELECTED_YEAR", in: animation)
                            } else {
                                Capsule()
                                    .fill(Color.gray.opacity(0.5))
                            }
                        }
                        .foregroundStyle(selectedYear == year ? .white : .primary)
                }
                .buttonStyle(.plain)
                .animation(.smooth(duration: 0.3, extraBounce: 0), value: selectedYear)
            }
        }
        .padding()
    }
}

#Preview {
    YearButtonsView(years: ["2022", "2023"], selectedYear: .constant("2022"))
}

