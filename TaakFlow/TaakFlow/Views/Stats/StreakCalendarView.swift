// StreakCalendarView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct StreakCalendarView: View {
    let days: [StatsViewModel.CalendarDay]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: TFSpacing.xs), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: TFSpacing.md) {
            Text("LAATSTE 30 DAGEN")
                .font(.tfCaption())
                .tracking(0.8)
                .foregroundColor(.tfTextSecondary)

            LazyVGrid(columns: columns, spacing: TFSpacing.xs) {
                ForEach(days) { day in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            day.isToday
                            ? Color.clear
                            : (day.hasCompletedTask ? Color.tfPriorityLow : Color.tfBorderLight)
                        )
                        .frame(height: 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(day.isToday ? Color.tfAccent : Color.clear, lineWidth: 1.5)
                        )
                }
            }
        }
        .padding(TFSpacing.lg)
        .background(Color.tfBgCard)
        .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
        .cardShadow()
    }
}
