import UserNotifications
import SwiftUI
import Observation

// @Observable replaces ObservableObject + @Published, which is incompatible
// with @MainActor in Swift 6 / Xcode 26.
@MainActor
@Observable
final class NotificationManager {
    static let shared = NotificationManager()

    var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private init() {
        checkAuthorizationStatus()
    }

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            authorizationStatus = granted ? .authorized : .denied
            return granted
        } catch {
            return false
        }
    }

    /// Schedules a local notification for the given task.
    /// No-op if the task has no due time or reminder enabled.
    func scheduleNotification(for task: TFTask) {
        guard let dueDate = task.dueDate,
              task.hasTime,
              task.hasReminder,
              dueDate > Date() else { return }

        cancelNotification(for: task)

        let content = UNMutableNotificationContent()
        content.title = task.title
        if let project = task.project { content.subtitle = project.name }
        content.sound = .default

        let comps = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: dueDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let identifier = task.id.uuidString
        let request = UNNotificationRequest(
            identifier: identifier, content: content, trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("TaakFlow: notification error – \(error.localizedDescription)")
            }
        }
        task.notificationID = identifier
    }

    func cancelNotification(for task: TFTask) {
        guard let nid = task.notificationID else { return }
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [nid])
        task.notificationID = nil
    }
}
