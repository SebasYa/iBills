//
//  GraphSectionView.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI
import Charts

struct GraphSectionView: View {
    @Binding var selectedDate: Date?
    @Binding var selectedIndex: Int?
    var title: String
    var data: [Double]
    @State private var lastDate: Date? = nil
    var dates: [Date]
    var color: Color
    
    var body: some View {
        Section(header: Text(title)) {
            if let selectedIndex = selectedIndex, selectedIndex < dates.count {
                let selectedDate = dates[selectedIndex]
                let selectedValue = data[selectedIndex]
                VStack {
                    Text("Fecha: \(selectedDate, formatter: dateFormatter)")
                    Text("\(title): \(selectedValue, specifier: "%.2f")")
                }
                .padding()
                .cornerRadius(5)
                .shadow(radius: 5)
                .padding(.bottom, 5)
            }
            // Chart displaying the data as a line graph
            Chart {
                ForEach(0..<dates.count, id: \.self) { index in
                    if data[index] != 0 {
                        LineMark(
                            x: .value("Fecha", dates[index], unit: .day),
                            y: .value(title, data[index])
                        )
                        .foregroundStyle(color)
                        .symbol(Circle())
                        .symbolSize(50)
                        .interpolationMethod(.linear)
                    }
                }
                if let selectedDate = selectedDate {
                    RuleMark(x: .value("Selected Date", selectedDate))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundStyle(.red)
                }
            }
            // Overlay to handle drag gestures for interacting with the chart
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle().fill(Color.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    updateSelection(value: value, proxy: proxy, geometry: geometry)
                                }
                                .onEnded { _ in
                                    selectedDate = nil
                                    selectedIndex = nil
                                    lastDate = nil
                                }
                        )
                }
            }
            .frame(height: 200)
        }
    }

    private func updateSelection(value: DragGesture.Value, proxy: ChartProxy, geometry: GeometryProxy) {
        guard let chartDate = chartDate(for: value.location.x, proxy: proxy, geometry: geometry) else {
            return
        }

        let roundedDate = Calendar.current.startOfDay(for: chartDate)
        selectedDate = chartDate

        if let lastDate, Calendar.current.isDate(lastDate, inSameDayAs: roundedDate) {
            return
        }

        selectedIndex = closestIndex(to: roundedDate)
        lastDate = roundedDate
    }

    private func chartDate(for xPosition: CGFloat, proxy: ChartProxy, geometry: GeometryProxy) -> Date? {
        let chartXPosition = xPosition - geometry.frame(in: .local).origin.x
        return proxy.value(atX: chartXPosition)
    }

    private func closestIndex(to date: Date) -> Int? {
        dates.enumerated().min { lhs, rhs in
            abs(lhs.element.timeIntervalSince(date)) < abs(rhs.element.timeIntervalSince(date))
        }?.offset
    }
}


let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()


#Preview {
    @Previewable @State var selectedIndex: Int? = nil
    @Previewable @State var selectedDate: Date? = nil

    let exampleDates = [
        Date(),
        Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
        Calendar.current.date(byAdding: .day, value: 2, to: Date())!
    ]
    
    let exampleData = [100.0, 200.0, 150.0]
    
    return GraphSectionView(
        selectedDate: $selectedDate,
        selectedIndex: $selectedIndex,
        title: "IVA Crédito",
        data: exampleData,
        dates: exampleDates,
        color: .green
    )
}
