import SwiftUI
import UserNotifications

// MARK: - Settings

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: String = "system"

    var body: some View {
        NavigationStack {
            List {
                // Appearance
                Section("Appearance") {
                    HStack {
                        Label("Theme", systemImage: "circle.lefthalf.filled")
                        Spacer()
                        Picker("Theme", selection: $appTheme) {
                            Text("Light").tag("light")
                            Text("Dark").tag("dark")
                            Text("System").tag("system")
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                }

                // Organisation
                Section("Organisation") {
                    NavigationLink {
                        TagsManagementView()
                    } label: {
                        Label("Manage Tags", systemImage: "tag")
                    }
                }

                // Notifications
                Section("Notifications") {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label("Notification Settings", systemImage: "bell")
                    }
                }

                // About
                Section("About") {
                    LabeledContent("App", value: "TaakFlow")
                    LabeledContent("Studio", value: "Vancoillie Studio")
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "1")
                    Link(destination: URL(string: "https://vancoilliestudio.be/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    Link(destination: URL(string: "mailto:support@vancoilliestudio.be")!) {
                        Label("Contact Support", systemImage: "envelope")
                    }
                }

                Section {
                    Text("TaakFlow stores all data locally on your device. No data is sent to any server. No accounts required.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Notification Settings

struct NotificationSettingsView: View {
    // @Observable singleton — @State holds the reference so SwiftUI tracks property access
    @State private var notificationManager = NotificationManager.shared

    var body: some View {
        List {
            Section("Status") {
                switch notificationManager.authorizationStatus {
                case .authorized, .provisional:
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Notifications are enabled")
                    }

                case .denied:
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                            Text("Notifications are disabled")
                        }
                        Text("Open iOS Settings to enable notifications for TaakFlow.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }

                case .notDetermined:
                    Button("Enable Notifications") {
                        Task { await notificationManager.requestPermission() }
                    }

                @unknown default:
                    Text("Notification status unknown")
                        .foregroundStyle(.secondary)
                }
            }

            Section("How it works") {
                Text("Reminders are sent at the exact time you set on a task. You must enable 'Specific time' and 'Reminder notification' when creating or editing a task.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Notifications")
        .onAppear { notificationManager.checkAuthorizationStatus() }
    }
}

#Preview {
    SettingsView()
}
