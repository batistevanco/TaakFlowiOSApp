//
//  ContentView.swift
//  TaakFlow
//
//  Created by Batiste Vancoillie on 10/03/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("appTheme") private var appTheme: String = "system"

    private var preferredColorScheme: ColorScheme? {
        switch appTheme {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }

            AllTasksView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }

            ProjectsView()
                .tabItem {
                    Label("Projects", systemImage: "folder.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .preferredColorScheme(preferredColorScheme)
    }
}

#Preview {
    let schema = Schema([TFTask.self, TFProject.self, TFTag.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    return ContentView().modelContainer(container)
}
