// CheckInViewModel.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData
import Observation

@Observable
class CheckInViewModel {
    // MARK: - Step state
    var currentStep: Int = 0
    var totalSteps: Int = 4

    // MARK: - Step 1 — Mood
    var selectedMoodScore: Int? = nil
    var selectedMoodEmoji: String = ""

    struct Mood: Identifiable {
        let id: Int
        let emoji: String
        let label: String
    }

    let moods: [Mood] = [
        Mood(id: 1, emoji: "😴", label: "Moe"),
        Mood(id: 2, emoji: "😐", label: "Gaat"),
        Mood(id: 3, emoji: "🙂", label: "Goed"),
        Mood(id: 4, emoji: "🔥", label: "Super"),
    ]

    // MARK: - Step 2 — Daily goal
    var dailyGoal: String = ""

    // MARK: - Step 3 — Projects
    var selectedProjectIDs: Set<UUID> = []

    // MARK: - Step 4 — Tasks
    var plannedTaskTitle1: String = ""
    var plannedTaskTitle2: String = ""
    var plannedTaskTitle3: String = ""

    var plannedTaskTitles: [String] {
        [plannedTaskTitle1, plannedTaskTitle2, plannedTaskTitle3].filter { !$0.isEmpty }
    }

    // MARK: - Navigation
    func goNext() {
        if currentStep < totalSteps - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                currentStep += 1
            }
        }
    }

    func goPrev() {
        if currentStep > 0 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                currentStep -= 1
            }
        }
    }

    var canGoNext: Bool {
        if currentStep == 0 { return selectedMoodScore != nil }
        return true
    }

    // MARK: - Save
    func saveCheckIn(projects: [TFProject], context: ModelContext) {
        let entry = CheckInEntry(
            moodScore: selectedMoodScore ?? 2,
            moodEmoji: selectedMoodEmoji,
            dailyGoal: dailyGoal,
            plannedTaskTitles: plannedTaskTitles,
            selectedProjectIDs: Array(selectedProjectIDs)
        )
        context.insert(entry)

        // Create planned tasks
        for title in plannedTaskTitles {
            let task = TFTask(title: title, timeBlock: .unscheduled, dueDate: Date())
            context.insert(task)
        }
    }

    // MARK: - Reset
    func reset() {
        currentStep = 0
        selectedMoodScore = nil
        selectedMoodEmoji = ""
        dailyGoal = ""
        selectedProjectIDs = []
        plannedTaskTitle1 = ""
        plannedTaskTitle2 = ""
        plannedTaskTitle3 = ""
    }
}
