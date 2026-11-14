//
//  Scenario.swift
//  ModelContainerTest
//

/// Each case is a separate `WindowGroup` in the app, configured a different way.
/// Open several windows of the same scenario, and windows of different scenarios,
/// then compare the container / context labels each window shows.
enum Scenario: String, CaseIterable, Identifiable {
    case sceneContainerInstanceA
    case sceneContainerInstanceB
    case sceneContainerForA
    case sceneContainerForB
    case sceneContainerForInMemory
    case sceneContextMain
    case sceneContextSeparate
    case viewContainerInstance
    case viewContainerFor
    case viewIndependentContext

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sceneContainerInstanceA: "Scene .modelContainer(shared) A"
        case .sceneContainerInstanceB: "Scene .modelContainer(shared) B"
        case .sceneContainerForA: "Scene .modelContainer(for:) A"
        case .sceneContainerForB: "Scene .modelContainer(for:) B"
        case .sceneContainerForInMemory: "Scene .modelContainer(for:inMemory: true)"
        case .sceneContextMain: "Scene .modelContext(shared.mainContext)"
        case .sceneContextSeparate: "Scene .modelContext(ModelContext(shared))"
        case .viewContainerInstance: "View .modelContainer(shared)"
        case .viewContainerFor: "View .modelContainer(for:)"
        case .viewIndependentContext: "View .modelContext(Memo { ModelContext(shared) })"
        }
    }
}
