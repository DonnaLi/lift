//
//  liftifyApp.swift
//  liftify
//
//  Created by Donna Li on 2026-02-22.
//

import SwiftUI
import SwiftData

@main
struct liftifyApp: App {
    @AppStorage("darkMode") private var darkMode = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @StateObject private var routineStore = RoutineStore.withDefaults()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(routineStore)
                .preferredColorScheme(darkMode ? .dark : .light)
        }
        .modelContainer(sharedModelContainer)
    }
}
