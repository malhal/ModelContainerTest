//
//  ContextProbeView.swift
//  ModelContainerTest
//

import SwiftUI
import SwiftData

/// Reports which `ModelContainer` and `ModelContext` this window received from the environment.
struct ContextProbeView: View {
    let title: String

    @Environment(\.modelContext) private var modelContext
    @Environment(\.undoManager) private var undoManager
    @Query(sort: \Item.timestamp) private var items: [Item]

    /// Identifies this particular window instance, so two windows of the same scenario can be told apart.
    @State private var windowID = UUID()

    private var registry: InstanceRegistry { .shared }

    private var containerLabel: String {
        registry.label(for: modelContext.container)
    }

    private var contextLabel: String {
        registry.label(for: modelContext)
    }

    private var isMainContext: Bool {
        modelContext === modelContext.container.mainContext
    }

    private var isInMemory: Bool {
        modelContext.container.configurations.contains { $0.isStoredInMemoryOnly }
    }

    private var storeURL: String {
        modelContext.container.configurations.first?.url.lastPathComponent ?? "-"
    }

    private var windowLabel: String {
        String(windowID.uuidString.prefix(8))
    }

    var body: some View {
        Form {
            Section(title) {
                LabeledContent("Window", value: windowLabel)
                LabeledContent("Container", value: containerLabel)
                LabeledContent("Context", value: contextLabel)
                LabeledContent("Is container.mainContext", value: isMainContext ? "YES" : "NO")
                LabeledContent("autosaveEnabled", value: modelContext.autosaveEnabled ? "YES" : "NO")
                LabeledContent("Context undoManager", value: modelContext.undoManager == nil ? "nil" : "set")
                LabeledContent("Env undoManager", value: undoManager == nil ? "nil" : "set")
                LabeledContent("In memory", value: isInMemory ? "YES" : "NO")
                LabeledContent("Store", value: storeURL)
            }

            Section("Items (\(items.count))") {
                HStack {
                    Button("Add", action: addItem)
                    Button("Save", action: save)
                    Button("Delete All", role: .destructive, action: deleteAll)
                }
                ForEach(items) { item in
                    Text(item.timestamp, format: Date.FormatStyle(date: .omitted, time: .standard))
                }
            }
        }
        .formStyle(.grouped)
        .onAppear {
            print("[\(title)] window \(windowLabel): \(containerLabel), \(contextLabel), main=\(isMainContext), autosave=\(modelContext.autosaveEnabled)")
        }
    }

    private func addItem() {
        modelContext.insert(Item(timestamp: Date()))
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("[\(title)] save failed: \(error)")
        }
    }

    private func deleteAll() {
        for item in items {
            modelContext.delete(item)
        }
    }
}
