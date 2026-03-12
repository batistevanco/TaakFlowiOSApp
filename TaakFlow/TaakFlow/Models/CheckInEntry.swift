// CheckInEntry.swift
// TaakFlow — Vancoillie Studio

import Foundation
import SwiftData

@Model
class CheckInEntry {
    var id: UUID
    var date: Date
    var moodScore: Int              // 1–4
    var moodEmoji: String
    var dailyGoal: String
    var plannedTaskTitles: [String]
    var selectedProjectIDs: [UUID]
    var completedAt: Date

    // Evening reflection (future)
    var eveningNote: String?
    var satisfactionScore: Int?

    // MARK: - Init
    init(
        moodScore: Int,
        moodEmoji: String,
        dailyGoal: String,
        plannedTaskTitles: [String] = [],
        selectedProjectIDs: [UUID] = []
    ) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: Date())
        self.moodScore = moodScore
        self.moodEmoji = moodEmoji
        self.dailyGoal = dailyGoal
        self.plannedTaskTitles = plannedTaskTitles
        self.selectedProjectIDs = selectedProjectIDs
        self.completedAt = Date()
    }
}
