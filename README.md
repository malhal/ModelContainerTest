# ModelContainerTest

A SwiftUI + SwiftData test harness that answers one question:

> For each way of supplying a `ModelContainer` / `ModelContext` to a scene or view, what container and context does each window actually end up with?

That is, which configurations give you:

- a shared container **and** a shared `mainContext`,
- a shared container with **separate contexts**, or
- **completely independent containers** (and therefore independent contexts).

## Hypothesis

> With multiple scenes, the built-in modifiers only let you have either a completely shared container and `mainContext`, or totally independent containers and therefore independent contexts.

**Result:** the hypothesis holds for the `.modelContainer` modifiers, which never make a new context. It does **not** hold in general: the built-in `.modelContext(_:)` modifier, given a `ModelContext` you create yourself, gives you a separate context on a shared container (see [Conclusions](#conclusions)).

## How the harness works

| File | Purpose |
|---|---|
| `ModelContainerTestApp.swift` | Declares one `WindowGroup` per scenario, each configured a different way. Creates one shared `ModelContainer` and one separate `ModelContext(sharedModelContainer)` in `init()`. |
| `ContentView.swift` | The launcher window. Has an `openWindow` button for each scenario, and probes its own environment (it uses Scene `.modelContainer(shared)`). |
| `ContextProbeView.swift` | Shows what the window received from the environment (details below). Also prints one line to the console when the window appears. |
| `InstanceRegistry.swift` | Gives each container and context a stable label such as `Container 1`, `Container 1.mainContext` or `Context 5 (on Container 1)`. It keeps every instance alive, so a new object can't reuse an old one's `ObjectIdentifier` and look identical. |
| `Scenario.swift` | An enum of the scenarios: window IDs and titles. |
| `Memo.swift` | A generic `Memo` class, plus an `independentModelContext(_:)` view modifier. The modifier gives each view instance (each window) its own `ModelContext` on a shared container, with stable identity across redraws. |

### What each window shows

- A per-window ID, so two windows of the same scenario can be told apart.
- The container and context labels.
- Whether the context is `container.mainContext`.
- `autosaveEnabled`, the context's `undoManager` and the environment's `undoManager`.
- Whether the store is in memory, and the store filename.
- A live `@Query` list of items, with **Add**, **Save** and **Delete All** buttons, for testing how changes propagate between windows.

### Running it

Run on macOS or an iPad simulator. From the launcher, open two windows of each scenario, then compare the labels shown in each window or printed to the console.

## Scenarios

| # | Configuration | Question |
|---|---|---|
| 1 | Scene `.modelContainer(shared)`, on two different scenes (A, B) plus the launcher | Do separate scenes given the same container instance share one context, and is it `mainContext`? |
| 2 | Scene `.modelContainer(for: Item.self)`, on two scenes (A, B) | One container per scene declaration, or one per window? |
| 3 | Scene `.modelContainer(for: Item.self, inMemory: true)` | A separate in-memory container. |
| 4 | Scene `.modelContext(shared.mainContext)` | The shared main context, passed explicitly. |
| 5 | Scene `.modelContext(ModelContext(shared))`, created once in `App.init` | A non-main context shared by every window of one scene. |
| 6 | View `.modelContainer(shared)`, applied inside the window | Does the view-level modifier make a context per window? |
| 7 | View `.modelContainer(for: Item.self)`, applied inside the window | One container per window? |
| 8 | View `.independentModelContext(shared)` (custom, uses `Memo`) | Control case: a separate context per window on one container. |

## Results

Console output from one run, with two windows opened per scenario:

```
[Launcher: Scene .modelContainer(shared)] window 86F790BA: Container 1, Container 1.mainContext, main=true, autosave=true
[Scene .modelContainer(shared) A] window D1C88A32: Container 1, Container 1.mainContext, main=true, autosave=true
[Scene .modelContainer(shared) A] window 0C2B579C: Container 1, Container 1.mainContext, main=true, autosave=true
[Scene .modelContainer(shared) B] window 597D1858: Container 1, Container 1.mainContext, main=true, autosave=true
[Scene .modelContainer(shared) B] window AF698EA2: Container 1, Container 1.mainContext, main=true, autosave=true
[Scene .modelContainer(for:) A] window 5CDDC62A: Container 2, Container 2.mainContext, main=true, autosave=true
[Scene .modelContainer(for:) A] window C348E721: Container 2, Container 2.mainContext, main=true, autosave=true
[Scene .modelContainer(for:) B] window EA3E78F2: Container 3, Container 3.mainContext, main=true, autosave=true
[Scene .modelContainer(for:) B] window 87505BCC: Container 3, Container 3.mainContext, main=true, autosave=true
[Scene .modelContainer(for:inMemory: true)] window 469142D4: Container 4, Container 4.mainContext, main=true, autosave=true
[Scene .modelContainer(for:inMemory: true)] window 0EAF22EB: Container 4, Container 4.mainContext, main=true, autosave=true
[Scene .modelContext(shared.mainContext)] window 3821D91B: Container 1, Container 1.mainContext, main=true, autosave=true
[Scene .modelContext(shared.mainContext)] window 91409332: Container 1, Container 1.mainContext, main=true, autosave=true
[Scene .modelContext(ModelContext(shared))] window 2D1CE565: Container 1, Context 5 (on Container 1), main=false, autosave=true
[Scene .modelContext(ModelContext(shared))] window DB894DD1: Container 1, Context 5 (on Container 1), main=false, autosave=true
[View .modelContainer(shared)] window 84D0D3AA: Container 1, Container 1.mainContext, main=true, autosave=true
[View .modelContainer(shared)] window B072CB15: Container 1, Container 1.mainContext, main=true, autosave=true
[View .modelContainer(for:)] window 75AFA8E0: Container 5, Container 5.mainContext, main=true, autosave=true
[View .modelContainer(for:)] window 1FFD5CBC: Container 6, Container 6.mainContext, main=true, autosave=true
[View .modelContext(Memo { ModelContext(shared) })] window 0B50575D: Container 1, Context 8 (on Container 1), main=false, autosave=true
[View .modelContext(Memo { ModelContext(shared) })] window D493DEBB: Container 1, Context 9 (on Container 1), main=false, autosave=true
```

### Summary

| Modifier | Container | Context | Shared across |
|---|---|---|---|
| Scene `.modelContainer(shared)` (launcher, A, B) | 1 | `1.mainContext` | every scene and window using container 1 this way |
| Scene `.modelContext(shared.mainContext)` | 1 | `1.mainContext` | same as above |
| View `.modelContainer(shared)` | 1 | `1.mainContext` | same as above |
| Scene `.modelContainer(for:)` A | 2 | `2.mainContext` | windows of scene A only |
| Scene `.modelContainer(for:)` B | 3 | `3.mainContext` | windows of scene B only |
| Scene `.modelContainer(for:inMemory:)` | 4 | `4.mainContext` | windows of that scene |
| View `.modelContainer(for:)` | 5, 6 | each container's `mainContext` | nothing: a new container per window |
| Scene `.modelContext(ModelContext(shared))` | 1 | Context 5, not main | windows of that scene only |
| View `.independentModelContext(shared)` (custom `Memo`) | 1 | Contexts 8 and 9, not main | nothing: a new context per window |

The context numbers skip 6 and 7 because those labels went to the main contexts of containers 5 and 6. Every context that appeared is in the table.

## Conclusions

1. **The `.modelContainer` modifiers never make a new context.** Scene or view, instance or `for:`, the environment always gets `container.mainContext`. The docs say "a new context associated with this container", which is misleading. The only thing that varies is how far the container is shared.
2. **Scene `.modelContainer(for:)` makes one container per scene declaration.** Scenes A and B got containers 2 and 3, each shared by that scene's windows. Containers 1, 2 and 3 all point at the same `default.store` file, so this is the setup most likely to show stale data between windows.
3. **View `.modelContainer(for:)` makes one container per window.** This is the "totally independent" case, at window level rather than scene level.
4. **Separate contexts on one container are possible with built-in modifiers, if you create the context yourself.**
   - **Per scene:** Scene `.modelContext(ModelContext(shared))` works. Both windows of that scene got Context 5, which isn't the main context, while the other scenes on container 1 got `mainContext`.
   - **Per window:** no built-in modifier does this. You need to keep the context's identity stable yourself, as the `Memo`-based `independentModelContext(_:)` modifier does (Contexts 8 and 9).
5. **`ModelContext(container)` had autosave on.** Contexts created this way showed `autosaveEnabled == true` in both scenario 5 and scenario 8.

## Open questions / next steps

These runs only checked **identity**, not how **data propagates** between windows. To check propagation, add items in each of these pairs and watch whether the other window updates straight away, only after **Save**, or not at all:

- Context 5 versus the launcher (separate contexts, same container)
- Context 8 versus Context 9 (separate per-window contexts, same container)
- Container 2 versus Container 3 (separate containers, same store file)

Not tested: putting `.modelContext(ModelContext(shared))` inline in a `WindowGroup` content closure, with no `Memo`. The context would presumably be recreated each time the closure re-runs, losing its identity.

## Notes

- The console message `Unable to obtain a task name port right for pid …` is a system message and has nothing to do with the test.
