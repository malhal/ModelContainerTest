//
//  ContentView.swift
//  ModelContainerTest
//
//  Created by Malcolm Hall on 14/11/2026.
//

import SwiftUI
import SwiftData

/// The launcher window. Opens a window for each scenario and also probes its own
/// environment (it is configured with Scene `.modelContainer(shared)`).
struct ContentView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        NavigationStack {
            List {
                Section("Open a window") {
                    ForEach(Scenario.allCases) { scenario in
                        Button(scenario.title) {
                            openWindow(id: scenario.id)
                        }
                    }
                }
                Section {
                    ContextProbeView(title: "Launcher: Scene .modelContainer(shared)")
                        .frame(minHeight: 420)
                }
            }
            .navigationTitle("ModelContainer Test")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
