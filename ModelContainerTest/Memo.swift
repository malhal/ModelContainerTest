//
//  Memo.swift
//  ModelContainerTest
//

import SwiftUI
import SwiftData

/// Caches a value derived from an input key so it keeps its identity across
/// view redraws. The value is only rebuilt when the key changes.
/// Hold one in `@State` so the memo itself survives redraws.
@MainActor
final class Memo<Key: Equatable, Value> {
    private var cached: (key: Key, value: Value)?

    func callAsFunction(_ key: Key, make: () -> Value) -> Value {
        if let cached, cached.key == key {
            return cached.value
        }
        let value = make()
        cached = (key, value)
        return value
    }
    
    deinit {
        print("deinit")
    }
}

/// Gives the modified view its own `ModelContext` on the supplied container,
/// i.e. an independent context per view instance (per window) that shares one container.
struct IndependentModelContextModifier: ViewModifier {
    let container: ModelContainer
    @State private var memo = Memo<ObjectIdentifier, ModelContext>()

    private var context: ModelContext {
        memo(ObjectIdentifier(container)) {
            ModelContext(container)
        }
    }

    func body(content: Content) -> some View {
        content.modelContext(context)
    }
}

extension View {
    func independentModelContext(_ container: ModelContainer) -> some View {
        modifier(IndependentModelContextModifier(container: container))
    }
}
