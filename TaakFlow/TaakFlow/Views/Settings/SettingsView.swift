// SettingsView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // MARK: - AppStorage
    @AppStorage("checkinEnabled")       private var checkinEnabled = true
    @AppStorage("checkinTime")          private var checkinTimeStr = "08:00"
    @AppStorage("checkinShowMood")      private var checkinShowMood = true

    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("dailySummaryEnabled")  private var dailySummaryEnabled = true
    @AppStorage("dailySummaryTime")     private var dailySummaryTimeStr = "20:00"
    @AppStorage("overdueReminders")     private var overdueReminders = true

    @AppStorage("pomodoroMinutes")      private var pomodoroMinutes = 25
    @AppStorage("shortBreakMinutes")    private var shortBreakMinutes = 5
    @AppStorage("longBreakMinutes")     private var longBreakMinutes = 15
    @AppStorage("autoStartBreaks")      private var autoStartBreaks = false

    @AppStorage("colorScheme")          private var colorSchemeRaw = "system"
    @AppStorage("userName")             private var userName = ""

    @AppStorage("currentStreak")        private var currentStreak = 0
    @AppStorage("longestStreak")        private var longestStreak = 0

    @State private var showResetAlert = false
    @State private var showAbout = false
    @State private var showHelp = false

    // Time picker values
    private let checkinTimes = ["07:30", "08:00", "08:30", "09:00"]
    private let summaryTimes = ["19:00", "20:00", "21:00"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TFSpacing.xl) {
                    // Header
                    HStack {
                        Text("Instellingen ⚙️")
                            .font(.tfLargeTitle())
                            .foregroundColor(.tfTextPrimary)
                            .tracking(-1.0)
                        Spacer()
                    }
                    .padding(.horizontal, TFSpacing.lg)
                    .padding(.top, TFSpacing.lg)

                    // Streak badge
                    HStack(spacing: TFSpacing.md) {
                        Text("🔥")
                            .font(.system(size: 20))
                        Text("\(currentStreak) dagen streak")
                            .font(.tfHeadline())
                            .foregroundColor(Color(hex: "#D97706"))
                        Text("·")
                            .foregroundColor(.tfTextSecondary)
                        Text("Blijf consistent!")
                            .font(.tfSubheadline())
                            .foregroundColor(.tfTextSecondary)
                        Spacer()
                    }
                    .padding(TFSpacing.md)
                    .background(Color(hex: "#FFF7ED"))
                    .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
                    .padding(.horizontal, TFSpacing.lg)

                    // MARK: Planning (check-in + meldingen)
                    settingsSection("Planning") {
                        toggleRow(title: "Ochtend check-in", subtitle: "Dagelijkse vragenlijst bij opstart", isOn: $checkinEnabled)
                        if checkinEnabled {
                            Divider().padding(.leading, TFSpacing.lg)
                            timePickerRow(title: "Tijdstip check-in", options: checkinTimes, selection: $checkinTimeStr)
                            Divider().padding(.leading, TFSpacing.lg)
                            toggleRow(title: "Stemming tonen", subtitle: "Mood vraag in check-in", isOn: $checkinShowMood)
                        }
                        Divider().padding(.leading, TFSpacing.lg)
                        toggleRow(title: "Taak reminders", subtitle: "Push notificaties voor taken", isOn: $notificationsEnabled)
                        Divider().padding(.leading, TFSpacing.lg)
                        toggleRow(title: "Dagelijkse samenvatting", subtitle: "Elke avond een overzicht", isOn: $dailySummaryEnabled)
                        if dailySummaryEnabled {
                            Divider().padding(.leading, TFSpacing.lg)
                            timePickerRow(title: "Tijd samenvatting", options: summaryTimes, selection: $dailySummaryTimeStr)
                        }
                        Divider().padding(.leading, TFSpacing.lg)
                        toggleRow(title: "Overdue reminders", subtitle: "Herinnering voor verlopen taken", isOn: $overdueReminders)
                    }

                    // MARK: Focus & Pomodoro
                    settingsSection("Focus & Pomodoro") {
                        stepperRow(title: "Focus duur", value: $pomodoroMinutes, range: 5...60, step: 5, unit: "min")
                        Divider().padding(.leading, TFSpacing.lg)
                        stepperRow(title: "Korte pauze", value: $shortBreakMinutes, range: 1...30, step: 1, unit: "min")
                        Divider().padding(.leading, TFSpacing.lg)
                        stepperRow(title: "Lange pauze", value: $longBreakMinutes, range: 5...60, step: 5, unit: "min")
                        Divider().padding(.leading, TFSpacing.lg)
                        toggleRow(title: "Auto-start pauze", subtitle: "Automatisch doorgaan", isOn: $autoStartBreaks)
                    }

                    // MARK: Appearance
                    settingsSection("Uiterlijk") {
                        VStack(alignment: .leading, spacing: TFSpacing.sm) {
                            Text("Thema")
                                .font(.tfSubheadline())
                                .foregroundColor(.tfTextPrimary)
                                .padding(.horizontal, TFSpacing.lg)
                            Picker("", selection: $colorSchemeRaw) {
                                Text("Systeem").tag("system")
                                Text("Licht").tag("light")
                                Text("Donker").tag("dark")
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, TFSpacing.lg)
                        }
                        .padding(.vertical, TFSpacing.md)

                        Divider().padding(.leading, TFSpacing.lg)

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Naam")
                                    .font(.tfSubheadline())
                                    .foregroundColor(.tfTextPrimary)
                            }
                            Spacer()
                            TextField("Naam", text: $userName)
                                .font(.tfSubheadline())
                                .foregroundColor(.tfTextSecondary)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(.horizontal, TFSpacing.lg)
                        .padding(.vertical, TFSpacing.md)
                    }

                    // MARK: Data
                    settingsSection("Data") {
                        Button(action: { }) {
                            HStack {
                                Label("Exporteer taken", systemImage: "square.and.arrow.up")
                                    .font(.tfSubheadline())
                                    .foregroundColor(.tfAccent)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.tfTextSecondary)
                            }
                            .padding(.horizontal, TFSpacing.lg)
                            .padding(.vertical, TFSpacing.md)
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, TFSpacing.lg)

                        Button(action: { showResetAlert = true }) {
                            HStack {
                                Label("Reset alle data", systemImage: "trash")
                                    .font(.tfSubheadline())
                                    .foregroundColor(.tfPriorityHigh)
                                Spacer()
                            }
                            .padding(.horizontal, TFSpacing.lg)
                            .padding(.vertical, TFSpacing.md)
                        }
                        .buttonStyle(.plain)
                    }

                    // MARK: Info (over + support)
                    settingsSection("Info") {
                        HStack {
                            Text("TaakFlow")
                                .font(.tfSubheadline())
                                .foregroundColor(.tfTextPrimary)
                            Spacer()
                            Text("v1.0")
                                .font(.tfCaption2())
                                .foregroundColor(.tfTextSecondary)
                        }
                        .padding(.horizontal, TFSpacing.lg)
                        .padding(.vertical, TFSpacing.md)

                        Divider().padding(.leading, TFSpacing.lg)

                        Link(destination: URL(string: "https://vancoilliestudio.be")!) {
                            HStack {
                                Label("Vancoillie Studio", systemImage: "globe")
                                    .font(.tfSubheadline())
                                    .foregroundColor(.tfAccent)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.tfTextSecondary)
                            }
                            .padding(.horizontal, TFSpacing.lg)
                            .padding(.vertical, TFSpacing.md)
                        }

                        Divider().padding(.leading, TFSpacing.lg)

                        Button(action: { showHelp = true }) {
                            HStack {
                                Label("Help & Uitleg", systemImage: "questionmark.circle")
                                    .font(.tfSubheadline())
                                    .foregroundColor(.tfTextPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.tfTextSecondary)
                            }
                            .padding(.horizontal, TFSpacing.lg)
                            .padding(.vertical, TFSpacing.md)
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, TFSpacing.lg)

                        Button(action: {
                            if let url = URL(string: "mailto:support@vancoilliestudio.be?subject=TaakFlow%20Support") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Label("Contact opnemen", systemImage: "envelope")
                                    .font(.tfSubheadline())
                                    .foregroundColor(.tfAccent)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.tfTextSecondary)
                            }
                            .padding(.horizontal, TFSpacing.lg)
                            .padding(.vertical, TFSpacing.md)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 100)
                }
            }
            .background(Color.tfBgPrimary)
            .dismissKeyboardOnInteraction()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Klaar") { dismiss() }
                        .font(.tfSubheadline())
                        .foregroundColor(.tfAccent)
                }
            }
        }
        .dismissKeyboardOnInteraction()
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
        .alert("Reset alle data?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) { }
            Button("Annuleer", role: .cancel) {}
        } message: {
            Text("Alle taken, projecten en instellingen worden permanent verwijderd.")
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: TFSpacing.sm) {
            Text(title.uppercased())
                .font(.tfCaption())
                .tracking(0.8)
                .foregroundColor(.tfTextSecondary)
                .padding(.horizontal, TFSpacing.lg)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.tfBgCard)
            .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
            .cardShadow()
            .padding(.horizontal, TFSpacing.lg)
        }
    }

    @ViewBuilder
    private func toggleRow(title: String, subtitle: String? = nil, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.tfSubheadline())
                    .foregroundColor(.tfTextPrimary)
                if let sub = subtitle {
                    Text(sub)
                        .font(.tfCaption2())
                        .foregroundColor(.tfTextSecondary)
                }
            }
            Spacer()
            CustomToggle(isOn: isOn)
        }
        .padding(.horizontal, TFSpacing.lg)
        .padding(.vertical, TFSpacing.md)
    }

    @ViewBuilder
    private func timePickerRow(title: String, options: [String], selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: TFSpacing.sm) {
            Text(title)
                .font(.tfSubheadline())
                .foregroundColor(.tfTextPrimary)
                .padding(.horizontal, TFSpacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: TFSpacing.sm) {
                    ForEach(options, id: \.self) { time in
                        Button(action: { selection.wrappedValue = time }) {
                            Text(time)
                                .font(.tfCaption())
                                .foregroundColor(selection.wrappedValue == time ? .white : .tfTextSecondary)
                                .padding(.horizontal, TFSpacing.md)
                                .padding(.vertical, TFSpacing.sm)
                                .background(selection.wrappedValue == time ? Color.tfAccent : Color.tfBgSubtle)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(SpringButtonStyle())
                    }
                }
                .padding(.horizontal, TFSpacing.lg)
            }
        }
        .padding(.vertical, TFSpacing.md)
    }

    @ViewBuilder
    private func stepperRow(title: String, value: Binding<Int>, range: ClosedRange<Int>, step: Int, unit: String) -> some View {
        HStack {
            Text(title)
                .font(.tfSubheadline())
                .foregroundColor(.tfTextPrimary)
            Spacer()
            HStack(spacing: TFSpacing.sm) {
                Button(action: {
                    if value.wrappedValue - step >= range.lowerBound {
                        value.wrappedValue -= step
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.tfAccent)
                        .frame(width: 28, height: 28)
                        .background(Color.tfBgSubtle)
                        .clipShape(Circle())
                }
                .buttonStyle(SpringButtonStyle())

                Text("\(value.wrappedValue) \(unit)")
                    .font(.tfCaption())
                    .foregroundColor(.tfTextPrimary)
                    .frame(minWidth: 50, alignment: .center)

                Button(action: {
                    if value.wrappedValue + step <= range.upperBound {
                        value.wrappedValue += step
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.tfAccent)
                        .frame(width: 28, height: 28)
                        .background(Color.tfBgSubtle)
                        .clipShape(Circle())
                }
                .buttonStyle(SpringButtonStyle())
            }
        }
        .padding(.horizontal, TFSpacing.lg)
        .padding(.vertical, TFSpacing.md)
    }
}
