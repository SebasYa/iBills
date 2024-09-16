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
    var viewModel: GraphViewModel
    
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
                                    // Handle the drag gesture to update the selected date and index
                                    viewModel.handleDragGesture(value: value, proxy: proxy, geometry: geometry, currentSelectedDate: $selectedDate, currentSelectedIndex: $selectedIndex, lastDate: $lastDate)
                                }
                                .onEnded { _ in
                                    // Reset selections when the drag ends
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
        color: .green,
        viewModel: GraphViewModel()
    )
}
