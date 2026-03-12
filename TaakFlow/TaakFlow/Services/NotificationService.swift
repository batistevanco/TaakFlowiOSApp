// NotificationService.swift
// TaakFlow — Vancoillie Studio

import Foundation
import UserNotifications

// MARK: - NotificationService

class NotificationService {
    static let shared = NotificationService()
    private init() {}

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
        center.removePendingNotificationRequests(withIdentifiers: ["checkin-daily"])

        let content = UNMutableNotificationContent()
        content.title = "☀️ Goedemorgen!"
        content.body = "Klaar voor je dagelijkse check-in?"
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "checkin-daily", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Task Reminder
    func scheduleTaskReminder(for task: TFTask) {
        guard let dueTime = task.dueTime else { return }
        guard let reminderDate = Calendar.current.date(byAdding: .minute, value: -10, to: dueTime) else { return }
        guard reminderDate > Date() else { return }

        let center = UNUserNotificationCenter.current()
        let id = "task-reminder-\(task.id)"
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
            .removePendingNotificationRequests(withIdentifiers: ["task-reminder-\(task.id)"])
    }

    // MARK: - Daily Summary
    func scheduleDailySummary(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["daily-summary"])

        let content = UNMutableNotificationContent()
        content.title = "📋 Dagoverzicht"
        content.body = "Bekijk je voortgang van vandaag."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-summary", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Streak Risk
    func scheduleStreakRisk() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["streak-risk"])

        let content = UNMutableNotificationContent()
        content.title = "🔥 Streak gevaar!"
        content.body = "Je streak staat op het spel! Rond een taak af."
        content.sound = .default

        var components = DateComponents()
        components.hour = 21
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "streak-risk", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Cancel all
    func cancelAllTaskNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func cancelNotification(id: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id])
    }
}
