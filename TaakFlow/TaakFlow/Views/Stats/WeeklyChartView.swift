// WeeklyChartView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import Charts

struct WeeklyChartView: View {
    let data: [StatsViewModel.DayStats]

    @State private var selectedDay: StatsViewModel.DayStats? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: TFSpacing.md) {
            Text("DEZE WEEK")
                .font(.tfCaption())
                .tracking(0.8)
                .foregroundColor(.tfTextSecondary)

            Chart {
                ForEach(data) { day in
                    BarMark(
                        x: .value("Dag", day.date.shortWeekdayString),
                        y: .value("Taken", day.completed)
                    )
                    .foregroundStyle(
                        day.isToday
                        ? AnyShapeStyle(LinearGradient.tfHero)
                        : AnyShapeStyle(Color.tfAccent.opacity(0.5))
                    )
                    .cornerRadius(4)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel()
                        .font(.tfCaption2())
                        .foregroundStyle(Color.tfTextSecondary)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel()
                        .font(.tfCaption2())
                        .foregroundStyle(Color.tfTextSecondary)
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.tfBorderLight)
                }
            }
            .frame(height: 160)
            .tint(.tfAccent)
        }
        .padding(TFSpacing.lg)
        .background(Color.tfBgCard)
        .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
        .cardShadow()
    }
}
