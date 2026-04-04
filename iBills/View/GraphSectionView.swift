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
    var detailData: [Double]
    var detailLabel: String
    @State private var lastDate: Date? = nil
    var dates: [Date]
    var color: Color
    var domain: ClosedRange<Date>?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            if let selectedIndex = selectedIndex, selectedIndex < dates.count {
                let selectedDate = dates[selectedIndex]
                let selectedValue = detailData[selectedIndex]
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Fecha")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.65))
                        Text(selectedDate, formatter: dateFormatter)
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(detailLabel)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.65))
                        Text(InvoiceDisplayFormatter.currency(InvoiceDecimal.money(from: selectedValue)))
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .padding(.bottom, 5)
            }

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
                if let selectedIndex = selectedIndex, selectedIndex < dates.count {
                    RuleMark(x: .value("Selected Date", dates[selectedIndex]))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundStyle(.red)

                    PointMark(
                        x: .value("Selected Date", dates[selectedIndex], unit: .day),
                        y: .value(title, data[selectedIndex])
                    )
                    .foregroundStyle(.red)
                    .symbolSize(85)
                }
            }
            .chartXScale(domain: domain ?? defaultDomain)
            .chartXAxis {
                AxisMarks(values: quarterlyAxisValues) { value in
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.12))
                    AxisTick()
                        .foregroundStyle(.white.opacity(0.35))
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(axisMonthLabel(for: date))
                                .foregroundStyle(.white.opacity(0.72))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.12))
                    AxisTick()
                        .foregroundStyle(.white.opacity(0.35))
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.72))
                }
            }
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    updateSelection(value: value, proxy: proxy, geometry: geometry)
                                }
                        )
                }
            }
            .frame(height: 200)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.black.opacity(0.16))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func updateSelection(value: DragGesture.Value, proxy: ChartProxy, geometry: GeometryProxy) {
        guard let roundedDate = chartDate(for: value.location.x, proxy: proxy, geometry: geometry),
              let closestIndex = closestIndex(to: roundedDate) else {
            return
        }

        let closestDate = dates[closestIndex]
        selectedDate = closestDate

        if let lastDate, Calendar.current.isDate(lastDate, inSameDayAs: closestDate) {
            return
        }

        selectedIndex = closestIndex
        lastDate = closestDate
    }

    private func chartDate(for xPosition: CGFloat, proxy: ChartProxy, geometry: GeometryProxy) -> Date? {
        guard let plotFrame = proxy.plotFrame.map({ geometry[$0] }) else {
            return nil
        }
        let localX = xPosition - plotFrame.origin.x
        let clampedX = min(max(0, localX), plotFrame.size.width)

        guard let chartDate: Date = proxy.value(atX: clampedX) else {
            return nil
        }

        return Calendar.current.startOfDay(for: chartDate)
    }

    private func closestIndex(to date: Date) -> Int? {
        dates.enumerated().min { lhs, rhs in
            abs(lhs.element.timeIntervalSince(date)) < abs(rhs.element.timeIntervalSince(date))
        }?.offset
    }

    private var defaultDomain: ClosedRange<Date> {
        guard let firstDate = dates.first, let lastDate = dates.last else {
            let today = Calendar.current.startOfDay(for: .now)
            return today...today
        }

        if Calendar.current.isDate(firstDate, inSameDayAs: lastDate) {
            let start = Calendar.current.date(byAdding: .day, value: -1, to: firstDate) ?? firstDate
            let end = Calendar.current.date(byAdding: .day, value: 1, to: lastDate) ?? lastDate
            return start...end
        }

        return firstDate...lastDate
    }

    private var quarterlyAxisValues: [Date] {
        let range = domain ?? defaultDomain
        let calendar = graphCalendar
        let start = range.lowerBound

        return [0, 3, 6, 9].compactMap { offset in
            guard let date = calendar.date(byAdding: .month, value: offset, to: start),
                  date <= range.upperBound else {
                return nil
            }

            return date
        }
    }

    private func axisMonthLabel(for date: Date) -> String {
        let monthIndex = graphCalendar.component(.month, from: date) - 1
        guard graphMonthSymbols.indices.contains(monthIndex) else {
            return ""
        }

        return graphMonthSymbols[monthIndex]
            .replacingOccurrences(of: ".", with: "")
            .capitalized(with: graphLocale)
    }
}


let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.calendar = graphCalendar
    formatter.locale = graphLocale
    return formatter
}()

private let graphLocale = Locale(identifier: "es_AR")

private let graphCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = graphLocale
    return calendar
}()

private let graphMonthSymbols = graphCalendar.shortStandaloneMonthSymbols


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
        detailData: [100.0, 100.0, -50.0],
        detailLabel: "IVA del día",
        dates: exampleDates,
        color: .green,
        domain: exampleDates.first!...exampleDates.last!
    )
}
