//
//  ModelContainerTestApp.swift
//  ModelContainerTest
//
//  Created by Malcolm Hall on 14/11/2026.
//

import SwiftUI
import SwiftData

@main
struct ModelContainerTestApp: App {
    /// One container instance passed explicitly to several scenes/views.
    let sharedModelContainer: ModelContainer

    /// A non-main context on the shared container, created once and handed to a scene.
    let separateContext: ModelContext

    init() {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        separateContext = ModelContext(sharedModelContainer)
    }

    var body: some Scene {
        // Launcher
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)

        // MARK: Scene-level container modifiers

        // Two different scenes given the same container instance: same context, or one per scene?
        WindowGroup(Scenario.sceneContainerInstanceA.title, id: Scenario.sceneContainerInstanceA.id) {
            ContextProbeView(title: Scenario.sceneContainerInstanceA.title)
        }
        .modelContainer(sharedModelContainer)

        WindowGroup(Scenario.sceneContainerInstanceB.title, id: Scenario.sceneContainerInstanceB.id) {
            ContextProbeView(title: Scenario.sceneContainerInstanceB.title)
        }
        .modelContainer(sharedModelContainer)

        // Two scenes each creating their own container: one container per scene, or per window?
        WindowGroup(Scenario.sceneContainerForA.title, id: Scenario.sceneContainerForA.id) {
            ContextProbeView(title: Scenario.sceneContainerForA.title)
        }
        .modelContainer(for: Item.self)

        WindowGroup(Scenario.sceneContainerForB.title, id: Scenario.sceneContainerForB.id) {
            ContextProbeView(title: Scenario.sceneContainerForB.title)
        }
        .modelContainer(for: Item.self)

        WindowGroup(Scenario.sceneContainerForInMemory.title, id: Scenario.sceneContainerForInMemory.id) {
            ContextProbeView(title: Scenario.sceneContainerForInMemory.title)
        }
        .modelContainer(for: Item.self, inMemory: true)

        // MARK: Scene-level context modifiers

        WindowGroup(Scenario.sceneContextMain.title, id: Scenario.sceneContextMain.id) {
            ContextProbeView(title: Scenario.sceneContextMain.title)
        }
        .modelContext(sharedModelContainer.mainContext)

        WindowGroup(Scenario.sceneContextSeparate.title, id: Scenario.sceneContextSeparate.id) {
            ContextProbeView(title: Scenario.sceneContextSeparate.title)
        }
        .modelContext(separateContext)

        // MARK: View-level modifiers (applied inside each window's root view)

        WindowGroup(Scenario.viewContainerInstance.title, id: Scenario.viewContainerInstance.id) {
            ContextProbeView(title: Scenario.viewContainerInstance.title)
                .modelContainer(sharedModelContainer)
        }

        WindowGroup(Scenario.viewContainerFor.title, id: Scenario.viewContainerFor.id) {
            ContextProbeView(title: Scenario.viewContainerFor.title)
                .modelContainer(for: Item.self)
        }

        WindowGroup(Scenario.viewIndependentContext.title, id: Scenario.viewIndependentContext.id) {
            ContextProbeView(title: Scenario.viewIndependentContext.title)
                .independentModelContext(sharedModelContainer)
        }
    }
}
