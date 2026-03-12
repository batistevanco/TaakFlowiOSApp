// StatsView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData

struct StatsView: View {
    @Query private var allTasks: [TFTask]
    @Query(filter: #Predicate<TFProject> { !$0.isArchived }) private var activeProjects: [TFProject]

    @AppStorage("currentStreak") private var currentStreak = 0
    @AppStorage("longestStreak") private var longestStreak = 0

    @State private var viewModel = StatsViewModel()

    private var weeklyData: [StatsViewModel.DayStats] { viewModel.weeklyStats(tasks: allTasks) }
    private var calendarDays: [StatsViewModel.CalendarDay] { viewModel.last30Days(tasks: allTasks) }
    private var insights: [String] { viewModel.generateInsights(tasks: allTasks) }
    private var totalThisWeek: Int { viewModel.totalCompletedThisWeek(tasks: allTasks) }
    private var focusTime: Int { viewModel.focusTimeThisWeek(tasks: allTasks) }

    // Week label
    private var weekLabel: String {
        let days = Date().daysInCurrentWeek
        guard let first = days.first, let last = days.last else { return "" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "nl_BE")
        f.dateFormat = "d"
        let month = DateFormatter()
        month.locale = Locale(identifier: "nl_BE")
        month.dateFormat = "MMMM"
        return "Week van \(f.string(from: first))–\(f.string(from: last)) \(month.string(from: last))"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: TFSpacing.lg) {
                    // Header
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: TFSpacing.xs) {
                            Text(weekLabel)
                                .font(.tfCaption())
                                .tracking(0.5)
                                .foregroundColor(.tfTextSecondary)
                                .textCase(.uppercase)
                            Text("Inzichten 📊")
                                .font(.tfLargeTitle())
                                .foregroundColor(.tfTextPrimary)
                                .tracking(-1.0)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, TFSpacing.lg)
                    .padding(.top, TFSpacing.lg)

                    // Weekly chart
                    WeeklyChartView(data: weeklyData)
                        .padding(.horizontal, TFSpacing.lg)

                    // Streak section
                    streakSection

                    // Summary cards
                    summaryCards

                    // Tag breakdown
                    let breakdown = viewModel.tagBreakdown(tasks: allTasks)
                    if !breakdown.isEmpty {
                        tagBreakdownView(breakdown: breakdown)
                    }

                    // Insights
                    insightsSection

                    Spacer(minLength: 100)
                }
                .padding(.top, TFSpacing.xs)
            }
            .background(Color.tfBgPrimary)
        }
    }

    // MARK: - Streak Section

    private var streakSection: some View {
        VStack(alignment: .leading, spacing: TFSpacing.md) {
            HStack(spacing: TFSpacing.xl) {
                VStack(alignment: .leading, spacing: TFSpacing.xs) {
                    HStack(alignment: .bottom, spacing: TFSpacing.sm) {
                        Text("🔥")
                            .font(.system(size: 32))
                        Text("\(currentStreak)")
                            .font(.system(size: 42, weight: .heavy))
                            .foregroundColor(Color(hex: "#D97706"))
                            .tracking(-1.5)
                    }
                    Text("Dagen streak")
                        .font(.tfSubheadline())
                        .foregroundColor(.tfTextSecondary)
                    Text("Langste streak: \(longestStreak) dagen")
                        .font(.tfCaption2())
                        .foregroundColor(.tfTextSecondary)
                }
                Spacer()
            }
            .padding(TFSpacing.lg)
            .background(Color.tfBgCard)
            .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
            .cardShadow()

            // 30-day calendar
            StreakCalendarView(days: calendarDays)
        }
        .padding(.horizontal, TFSpacing.lg)
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: TFSpacing.md) {
            summaryCard(emoji: "✅", value: "\(totalThisWeek)", label: "Voltooid")
            summaryCard(emoji: "🔥", value: "\(currentStreak)", label: "Streak")
            summaryCard(emoji: "📁", value: "\(activeProjects.count)", label: "Projecten")
            summaryCard(emoji: "⏱", value: focusTime > 0 ? "\(focusTime)m" : "–", label: "Focus tijd")
        }
        .padding(.horizontal, TFSpacing.lg)
    }

    private func summaryCard(emoji: String, value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: TFSpacing.xs) {
            Text(emoji).font(.system(size: 18))
            Text(value)
                .font(.system(size: 28, weight: .heavy))
                .foregroundColor(.tfTextPrimary)
                .tracking(-0.5)
            Text(label)
                .font(.tfCaption())
                .foregroundColor(.tfTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(TFSpacing.lg)
        .background(Color.tfBgCard)
        .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
        .cardShadow()
    }

    // MARK: - Tag Breakdown

    private func tagBreakdownView(breakdown: [StatsViewModel.TagBreakdown]) -> some View {
        VStack(alignment: .leading, spacing: TFSpacing.md) {
            Text("CATEGORIEËN")
                .font(.tfCaption())
                .tracking(0.8)
                .foregroundColor(.tfTextSecondary)
                .padding(.horizontal, TFSpacing.lg)

            VStack(spacing: TFSpacing.sm) {
                ForEach(breakdown) { item in
                    HStack {
                        SmallTagPill(name: item.tagName, color: item.color)
                        Spacer()
                        Text("\(item.count) taken")
                            .font(.tfCaption2())
                            .foregroundColor(.tfTextSecondary)
                    }
                    .padding(TFSpacing.md)
                    .background(Color.tfBgCard)
                    .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
                }
            }
            .padding(.horizontal, TFSpacing.lg)
        }
    }

    // MARK: - Insights

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: TFSpacing.md) {
            Text("INZICHTEN")
                .font(.tfCaption())
                .tracking(0.8)
                .foregroundColor(.tfTextSecondary)
                .padding(.horizontal, TFSpacing.lg)

            VStack(spacing: TFSpacing.sm) {
                ForEach(insights, id: \.self) { insight in
                    HStack(alignment: .top, spacing: TFSpacing.md) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.tfPriorityMed)
                            .padding(.top, 2)
                        Text(insight)
                            .font(.tfBody())
                            .foregroundColor(.tfTextPrimary)
                    }
                    .padding(TFSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.tfBgCard)
                    .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
                    .cardShadow()
                }
            }
            .padding(.horizontal, TFSpacing.lg)
        }
    }
}
