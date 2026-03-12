// TodayStatsRow.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct TodayStatsRow: View {
    let streakCount: Int
    let urgentCount: Int
    let projectsCount: Int

    var body: some View {
        HStack(spacing: TFSpacing.md) {
            StatCard(emoji: "🔥", value: "\(streakCount)", label: "Dag streak")
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.9)),
                    removal: .opacity
                ))
                .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.0), value: streakCount)

            StatCard(emoji: "⚡", value: "\(urgentCount)", label: "Urgent")
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.9)),
                    removal: .opacity
                ))
                .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.05), value: urgentCount)

            StatCard(emoji: "📁", value: "\(projectsCount)", label: "Projecten")
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.9)),
                    removal: .opacity
                ))
                .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.10), value: projectsCount)
        }
    }
}

// MARK: - StatCard

private struct StatCard: View {
    let emoji: String
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: TFSpacing.xs) {
            Text(emoji)
                .font(.system(size: 16))
            Text(value)
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(.tfTextPrimary)
                .tracking(-0.5)
            Text(label)
                .font(.tfCaption2())
                .foregroundColor(.tfTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(TFSpacing.md)
        .background(Color.tfBgCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .cardShadow()
    }
}

#Preview {
    TodayStatsRow(streakCount: 7, urgentCount: 3, projectsCount: 4)
        .padding()
        .background(Color.tfBgPrimary)
}
