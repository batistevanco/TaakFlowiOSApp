//
//  TaakFlowApp.swift
//  TaakFlow
//
//  Created by Batiste Vancoillie on 10/03/2026.
//

import SwiftUI
import SwiftData

@main
struct TaakFlowApp: App {

    let container: ModelContainer = {
        let schema = Schema([TFTask.self, TFProject.self, TFTag.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("TaakFlow: could not create ModelContainer – \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
