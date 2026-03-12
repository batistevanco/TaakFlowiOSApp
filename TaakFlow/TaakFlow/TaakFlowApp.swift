// TaakFlowApp.swift
// TaakFlow — Vancoillie Studio · be.vancoilliestudio.taakflow
// Created by Batiste Vancoillie on 10/03/2026.

import SwiftUI
import SwiftData

@main
struct TaakFlowApp: App {

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("colorScheme") private var colorSchemeRaw = "system"

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingView()
                }
            }
            .preferredColorScheme(resolvedColorScheme)
        }
        .modelContainer(for: [
            TFTask.self,
            TFProject.self,
            TFTag.self,
            CheckInEntry.self
        ])
    }

    private var resolvedColorScheme: ColorScheme? {
        switch colorSchemeRaw {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }
}
