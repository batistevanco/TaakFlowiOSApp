// ContentView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var allTasks: [TFTask]
    @Query private var checkInEntries: [CheckInEntry]

    @AppStorage("checkinEnabled")  private var checkinEnabled = true
    @AppStorage("checkinTime")     private var checkinTimeStr = "08:00"
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("dailySummaryEnabled") private var dailySummaryEnabled = true
    @AppStorage("dailySummaryTime") private var dailySummaryTimeStr = "20:00"
    @AppStorage("overdueReminders") private var overdueReminders = true

    @State private var selectedTab: Int = 0
    @State private var showSettings = false
    @State private var showCheckIn = false

    private var notificationSettingsToken: String {
        [
            checkinEnabled.description,
            checkinTimeStr,
            notificationsEnabled.description,
            dailySummaryEnabled.description,
            dailySummaryTimeStr,
            overdueReminders.description
        ].joined(separator: "|")
    }

    private var taskNotificationToken: String {
        allTasks
            .map { task in
                [
                    task.id.uuidString,
                    task.title,
                    task.isDone.description,
                    task.dueDate?.ISO8601Format() ?? "nil",
                    task.dueTime?.ISO8601Format() ?? "nil"
                ].joined(separator: "#")
            }
            .sorted()
            .joined(separator: "|")
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(onOpenSettings: { showSettings = true })
                .tabItem {
                    Label("Vandaag", systemImage: selectedTab == 0 ? "sun.max.fill" : "sun.max")
                }
                .tag(0)

            AllTasksView()
                .tabItem {
                    Label("Taken", systemImage: selectedTab == 1 ? "checkmark.square.fill" : "checkmark.square")
                }
                .tag(1)

            ProjectsView()
                .tabItem {
                    Label("Projecten", systemImage: selectedTab == 2 ? "folder.fill" : "folder")
                }
                .tag(2)

            StatsView()
                .tabItem {
                    Label("Inzichten", systemImage: selectedTab == 3 ? "chart.bar.fill" : "chart.bar")
                }
                .tag(3)
        }
        .tint(.tfAccent)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showCheckIn) {
            MorningCheckInView()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
        ) { _ in
            checkForCheckIn()
            syncNotifications()
        }
        .onAppear {
            configureTabBar()
            checkForCheckIn()
            syncNotifications()
        }
        .onChange(of: notificationSettingsToken) { _, _ in
            syncNotifications()
        }
        .onChange(of: taskNotificationToken) { _, _ in
            syncNotifications()
        }
    }

    // MARK: - Morning Check-in Trigger

    private func checkForCheckIn() {
        guard checkinEnabled else { return }
        guard !hasCompletedCheckInToday() else { return }
        guard isWithinCheckInWindow() else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showCheckIn = true
        }
    }

    private func hasCompletedCheckInToday() -> Bool {
        checkInEntries.contains { entry in
            Calendar.current.isDateInToday(entry.date)
        }
    }

    private func isWithinCheckInWindow() -> Bool {
        let parts = checkinTimeStr.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]) else { return false }

        let now = Date()
        let cal = Calendar.current
        guard let checkinDate = cal.date(bySettingHour: hour, minute: minute, second: 0, of: now) else { return false }
        guard let windowEnd = cal.date(byAdding: .minute, value: 30, to: checkinDate) else { return false }

        return now >= checkinDate && now <= windowEnd
    }

    private func syncNotifications() {
        Task {
            await NotificationService.shared.syncNotificationSettings(
                checkinEnabled: checkinEnabled,
                checkinTime: checkinTimeStr,
                notificationsEnabled: notificationsEnabled,
                dailySummaryEnabled: dailySummaryEnabled,
                dailySummaryTime: dailySummaryTimeStr,
                overdueReminders: overdueReminders,
                tasks: allTasks
            )
        }
    }

    // MARK: - Tab Bar Appearance

    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.container)
}
