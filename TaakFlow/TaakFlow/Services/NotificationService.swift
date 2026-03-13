// NotificationService.swift
// TaakFlow — Vancoillie Studio

import Foundation
import UserNotifications

// MARK: - NotificationService

class NotificationService {
    static let shared = NotificationService()
    private init() {}

    private let checkInNotificationID = "checkin-daily"
    private let dailySummaryNotificationID = "daily-summary"
    private let overdueReminderNotificationID = "overdue-daily"
    private let taskReminderPrefix = "task-reminder-"

    // MARK: - Permission
    @discardableResult
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }

    // MARK: - Schedule Check-in
    func scheduleCheckIn(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [checkInNotificationID])

        let content = UNMutableNotificationContent()
        content.title = "☀️ Goedemorgen!"
        content.body = "Klaar voor je dagelijkse check-in?"
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: checkInNotificationID, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Task Reminder
    func scheduleTaskReminder(for task: TFTask) {
        guard let dueDate = task.dueDate, let dueTime = task.dueTime, !task.isDone else { return }

        var components = Calendar.current.dateComponents([.year, .month, .day], from: dueDate)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: dueTime)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute

        guard let scheduledDueDate = Calendar.current.date(from: components) else { return }
        guard let reminderDate = Calendar.current.date(byAdding: .minute, value: -10, to: scheduledDueDate) else { return }
        guard reminderDate > Date() else { return }

        let center = UNUserNotificationCenter.current()
        let id = "\(taskReminderPrefix)\(task.id)"
        center.removePendingNotificationRequests(withIdentifiers: [id])

        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body = "is over 10 minuten!"
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelTaskNotification(for task: TFTask) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["\(taskReminderPrefix)\(task.id)"])
    }

    // MARK: - Daily Summary
    func scheduleDailySummary(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailySummaryNotificationID])

        let content = UNMutableNotificationContent()
        content.title = "📋 Dagoverzicht"
        content.body = "Bekijk je voortgang van vandaag."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: dailySummaryNotificationID, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Overdue Reminder
    func scheduleOverdueReminder(hour: Int = 9, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [overdueReminderNotificationID])

        let content = UNMutableNotificationContent()
        content.title = "⚠️ Verlopen taken"
        content.body = "Je hebt taken die aandacht nodig hebben."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: overdueReminderNotificationID, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Sync
    func syncNotificationSettings(
        checkinEnabled: Bool,
        checkinTime: String,
        notificationsEnabled: Bool,
        dailySummaryEnabled: Bool,
        dailySummaryTime: String,
        overdueReminders: Bool,
        tasks: [TFTask]
    ) async {
        if !notificationsEnabled {
            cancelNotification(id: checkInNotificationID)
            cancelNotification(id: dailySummaryNotificationID)
            cancelNotification(id: overdueReminderNotificationID)
            await cancelPendingNotifications(withPrefix: taskReminderPrefix)
            return
        }

        let authorizationStatus = await notificationAuthorizationStatus()
        if authorizationStatus == .notDetermined {
            _ = await requestPermission()
        }

        if checkinEnabled, let checkInTime = parseTime(checkinTime) {
            scheduleCheckIn(hour: checkInTime.hour, minute: checkInTime.minute)
        } else {
            cancelNotification(id: checkInNotificationID)
        }

        if dailySummaryEnabled, let summaryTime = parseTime(dailySummaryTime) {
            scheduleDailySummary(hour: summaryTime.hour, minute: summaryTime.minute)
        } else {
            cancelNotification(id: dailySummaryNotificationID)
        }

        if overdueReminders && tasks.contains(where: \.isOverdue) {
            scheduleOverdueReminder()
        } else {
            cancelNotification(id: overdueReminderNotificationID)
        }

        await syncTaskReminders(for: tasks, enabled: notificationsEnabled)
    }

    // MARK: - Cancel all
    func cancelAllTaskNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func cancelNotification(id: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id])
    }

    private func syncTaskReminders(for tasks: [TFTask], enabled: Bool) async {
        await cancelPendingNotifications(withPrefix: taskReminderPrefix)

        guard enabled else { return }
        for task in tasks {
            scheduleTaskReminder(for: task)
        }
    }

    private func cancelPendingNotifications(withPrefix prefix: String) async {
        let center = UNUserNotificationCenter.current()
        let pendingRequests = await pendingNotificationRequests()
        let ids = pendingRequests
            .map(\.identifier)
            .filter { $0.hasPrefix(prefix) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    private func pendingNotificationRequests() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }

    private func notificationAuthorizationStatus() async -> UNAuthorizationStatus {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                continuation.resume(returning: settings.authorizationStatus)
            }
        }
    }

    private func parseTime(_ value: String) -> (hour: Int, minute: Int)? {
        let parts = value.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]) else { return nil }
        return (hour, minute)
    }
}
