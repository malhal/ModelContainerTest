//
//  InstanceRegistry.swift
//  ModelContainerTest
//

import SwiftData

/// Assigns stable, human-readable labels ("Container 2", "Context 5") to every
/// `ModelContainer` / `ModelContext` instance seen, so identity can be compared across windows.
///
/// Instances are retained deliberately so their `ObjectIdentifier`s can never be reused
/// by a later allocation, which would make two different objects look identical.
/// Not observable on purpose: it's mutated while views compute their labels.
@MainActor
final class InstanceRegistry {
    static let shared = InstanceRegistry()

    private var containerLabels: [ObjectIdentifier: String] = [:]
    private var contextLabels: [ObjectIdentifier: String] = [:]
    private var retained: [AnyObject] = []

    func label(for container: ModelContainer) -> String {
        let id = ObjectIdentifier(container)
        if let label = containerLabels[id] {
            return label
        }
        let label = "Container \(containerLabels.count + 1)"
        containerLabels[id] = label
        retained.append(container)

        // Pre-label the container's main context so it is recognisable wherever it shows up.
        let mainContext = container.mainContext
        contextLabels[ObjectIdentifier(mainContext)] = "\(label).mainContext"
        retained.append(mainContext)
        return label
    }

    func label(for context: ModelContext) -> String {
        let containerLabel = label(for: context.container)
        let id = ObjectIdentifier(context)
        if let label = contextLabels[id] {
            return label
        }
        let label = "Context \(contextLabels.count + 1) (on \(containerLabel))"
        contextLabels[id] = label
        retained.append(context)
        return label
    }
}
