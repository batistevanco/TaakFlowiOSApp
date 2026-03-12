// PomodoroTimer.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import Observation
import Combine

// MARK: - Timer Phase

enum PomodoroPhase {
    case work, shortBreak, longBreak

    var label: String {
        switch self {
        case .work:       return "Focus"
        case .shortBreak: return "Korte pauze"
        case .longBreak:  return "Lange pauze"
        }
    }

    var emoji: String {
        switch self {
        case .work:       return "🎯"
        case .shortBreak: return "☕"
        case .longBreak:  return "🌿"
        }
    }
}

// MARK: - PomodoroTimer ViewModel

@Observable
class PomodoroTimer {
    // MARK: - Settings (injected)
    var workMinutes: Int
    var shortBreakMinutes: Int
    var longBreakMinutes: Int
    let sessionsBeforeLongBreak = 4

    // MARK: - State
    var phase: PomodoroPhase = .work
    var completedSessions: Int = 0
    var secondsRemaining: Int
    var isRunning: Bool = false
    var elapsedSeconds: Int = 0

    private var timerCancellable: AnyCancellable?

    // MARK: - Init
    init(workMinutes: Int = 25, shortBreakMinutes: Int = 5, longBreakMinutes: Int = 15) {
        self.workMinutes = workMinutes
        self.shortBreakMinutes = shortBreakMinutes
        self.longBreakMinutes = longBreakMinutes
        self.secondsRemaining = workMinutes * 60
    }

    // MARK: - Computed
    var totalSeconds: Int {
        switch phase {
        case .work:       return workMinutes * 60
        case .shortBreak: return shortBreakMinutes * 60
        case .longBreak:  return longBreakMinutes * 60
        }
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - Double(secondsRemaining) / Double(totalSeconds)
    }

    var timeString: String {
        let m = secondsRemaining / 60
        let s = secondsRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    var sessionDots: [Bool] {
        (0..<sessionsBeforeLongBreak).map { $0 < completedSessions % sessionsBeforeLongBreak }
    }

    // MARK: - Controls
    func start() {
        isRunning = true
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func pause() {
        isRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func reset() {
        pause()
        secondsRemaining = totalSeconds
        elapsedSeconds = 0
    }

    func stop() {
        pause()
        phase = .work
        completedSessions = 0
        secondsRemaining = workMinutes * 60
        elapsedSeconds = 0
    }

    // MARK: - Tick
    private func tick() {
        if secondsRemaining > 0 {
            secondsRemaining -= 1
            if phase == .work { elapsedSeconds += 1 }
        } else {
            timerEnded()
        }
    }

    private func timerEnded() {
        pause()
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        switch phase {
        case .work:
            completedSessions += 1
            let isLongBreak = completedSessions % sessionsBeforeLongBreak == 0
            phase = isLongBreak ? .longBreak : .shortBreak
            secondsRemaining = isLongBreak ? longBreakMinutes * 60 : shortBreakMinutes * 60
        case .shortBreak, .longBreak:
            phase = .work
            secondsRemaining = workMinutes * 60
        }
    }
}
