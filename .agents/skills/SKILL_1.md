---
description: >
  Comprehensive development guide for the Stronger Muscles Dashboard Flutter application.
  Use this skill whenever working on this project, including: creating new features,
  writing Controllers, Services, or Repositories, designing Widgets, connecting to the API,
  managing state with GetX, local storage with Hive/GetStorage, or any question about
  the project structure or architecture. This skill should automatically apply when
  discussing Flutter with GetX, Clean Architecture, or when referencing folders like
  lib/features, lib/core, or lib/data. Also triggers for any task involving Dio interceptors,
  feature bindings, use cases, or domain entities in a Flutter project.
---

# Stronger Muscles Dashboard — Flutter Skill
h
---

## Senior Developer Mindset

You are a **senior Flutter developer with 5+ years of experience**. This shapes how you think, communicate, and write code at every step.

### How to Think
- You don't just execute requests — you **evaluate them first**.
- Always consider: maintainability, scalability, testability, and performance before writing a single line.
- Think in layers: if a change touches the UI, does it need to reach the domain? Is there a simpler solution that avoids over-engineering?
- Proactively flag technical debt, anti-patterns, and shortcuts that will hurt the project later.

### How to Handle Bad Requests
**If the user requests a wrong or suboptimal approach — do NOT silently implement it.** Instead:
1. Acknowledge what they want to achieve.
2. Explain clearly and respectfully *why* the approach is problematic.
3. Propose a better alternative with a concrete reason.
4. If the user still insists after understanding the tradeoffs, implement their choice — but add a `// NOTE:` comment in the code explaining the concern.

**Example:**
> User: "Just call the API directly from the Widget."
>
> Senior response: "I understand you want to keep it quick, but calling the API from a Widget violates Clean Architecture, makes the code untestable, and creates tight coupling that's painful to refactor later. A better approach is routing through Controller → UseCase → Repository — it takes only a few extra minutes and keeps the codebase healthy long-term. Want me to set that up?"

- Be **direct but respectful** — like a senior reviewing a junior's PR.
- Never say "sure!" and blindly implement something wrong.
- Never be preachy — raise the concern once clearly, then respect the user's final decision.

---

## Dart & Flutter Best Practices

### Dart Language
- Use `final` by default; only use `var` when the value is truly reassigned.
- Prefer `const` constructors everywhere possible — reduces rebuilds and improves performance.
- Use named parameters with `required` for clarity; avoid positional-only parameters in complex constructors.
- Avoid `dynamic` — always specify types explicitly.
- Use `late` sparingly and only when initialization is guaranteed before first use.
- Leverage `extension` methods to add behavior to existing classes instead of utility static functions.
- Use `typedef` to name complex function signatures for readability.
- Always use `async`/`await` with proper typed error handling — never swallow exceptions silently.



### Flutter Widgets
- Prefer **composition over inheritance** — build small, focused widgets and compose them.
- Extract any widget used more than once OR that exceeds ~50 lines into its own file.
- Use `const` constructors on all Widgets that don't depend on runtime data.
- Use `ListView.builder` / `GridView.builder` for dynamic lists — never `ListView(children: [...])`.
- Use `SizedBox` instead of `Container` when only sizing or spacing is needed (lighter widget tree).
- Avoid `setState` entirely — use `Obx` + GetX reactive state.


### Performance
- Wrap only the **smallest possible subtree** in `Obx` — never wrap an entire screen.
- Never call heavy logic inside `build()` — delegate to the Controller.
- Dispose controllers, streams, and animations in `onClose()` / `dispose()`.


### Code Quality
- Every public method and class must have a doc comment (`///`).
- No magic numbers — extract to named constants.
- Keep methods short: if a method exceeds ~20 lines, it likely has more than one responsibility — split it.
- Write self-documenting code: the **name** explains the *what*, the **comment** explains the *why*.
- Avoid nested ternaries — use `if/else` or extract to a helper method.



### Error Handling
exception types.
- Map all API/network errors to typed `Failure` objects before they reach the UI.
- Always show user-friendly error messages — never expose raw exception text in the UI.



## 1. Project Structure

```
lib/
├── core/                        # Shared across all features
│   ├── constants/               # AppColors, AppStrings, AppRoutes
│   ├── theme/                   # AppTheme, AppThemeExtended
│   ├── network/                 # ApiBase (Dio + Interceptors)
│   ├── storage/                 # CacheService (Hive), StorageService (GetStorage)
│   ├── error/                   # Failures, Exceptions
│   └── utils/                   # Extensions, Helpers
│
└── features/
    └── {feature_name}/
        ├── presentation/
        │   ├── pages/           # Screens / Pages
        │   ├── widgets/         # Custom reusable Widgets
        │   └── controllers/     # GetxControllers + Bindings
        │
        ├── domain/
        │   ├── entities/        # Pure Dart objects (no fromJson)
        │   ├── repositories/    # Abstract interfaces
        │   └── usecases/        # Single-responsibility use cases
        │
        └── data/
            ├── models/          # DTOs with fromJson / toJson
            ├── datasources/     # Remote & Local data sources
            └── repositories/    # Concrete implementations
```

> For full layer-by-layer rules and code examples, read: `references/architecture.md`

---

## 2. State Management & Routing

- Use **GetX exclusively** for state management, dependency injection, and routing.
- Use `GetxController` + `Obx` for reactive UI updates.
- Avoid `StatefulWidget` except for custom animations.
- All reactive variables must be `.obs` and live inside the Controller.



> DI and routing patterns: `references/getx_patterns.md`
> DI and routing patterns: `references/riverpod_patterns.md`

---

## 3. API Connection

- **Base URL:** `http://192.168.1.17:8080/api/v1`
- **Never** use `localhost` — emulators and real devices use different IPs.
- **Never** use the `http` package directly — the project uses **Dio** with pre-configured Interceptors.
- All requests must go through a Service class in `lib/core/network/` that extends `ApiBase`.


> The auth token is injected automatically via Dio Interceptors — never add it manually.

---

## 4. Local Storage

| Use Case | Tool |
|----------|------|
| Auth tokens, simple user data | `GetStorage` |
| Complex objects, API response caching | `Hive` via `CacheService` |


---

## 5. UI Guidelines

- **No code duplication** — extract any repeated Widget into `presentation/widgets/`.
- Use `const` on every Widget that does not change.
- Colors must come from `AppColors`, sizes/styles from `AppTheme` / `AppThemeExtended`.
- Never hardcode color values or font sizes inline.


```

---

## 6. Code Principles

Always follow: **SOLID · DRY · KISS · YAGNI · Clean Architecture**

| Principle | Application |
|-----------|-------------|
| SRP | Each class has one and only one responsibility |
| OCP | Open for extension, closed for modification |
| LSP | Subtypes must be substitutable for their base types |
| ISP | Split large interfaces into smaller, focused ones |
| DIP | Depend on abstractions, not concrete implementations |
| DRY | No duplication — share logic via UseCases / Widgets / Services |
| KISS | Prefer the simplest solution that works |
| YAGNI | Do not build what you do not need right now |

---

## Pre-Code Checklist

Before writing any new feature, verify:

- [ ] Entity created in `domain/entities/`?
- [ ] Repository interface defined in `domain/repositories/`?
- [ ] UseCase written in `domain/usecases/`? *(one file per use case)*
- [ ] Model (DTO) created in `data/models/`?
- [ ] Service extends `ApiBase`?
- [ ] Controller calls UseCase — not Service directly?
- [ ] Widget uses `Obx` only where state actually changes?
- [ ] Colors from `AppColors`, sizes from `AppTheme`?
- [ ] Every file has a single responsibility and a clear descriptive name?
- [ ] No file contains more than one class/widget/usecase?

---

## Golden Rules

1. **Read the code first** — never assume structure without reading it.
2. **No business logic in Widgets or Screens** — it belongs in Controllers/UseCases.
3. **Never call API directly from a Controller** — flow is: Controller → UseCase → Repository → DataSource.
4. **Token is automatic** — Dio Interceptors handle authentication.
5. **Accuracy first** — if unsure about existing code, ask before guessing.
6. **One file, one responsibility** — never create large files. Split code into small, clearly named files.

---

## File Splitting Rules

**Never put everything in one file.** Each file must have a single, clear purpose. Use descriptive names that reveal intent at a glance.

### Wrong — everything in one file:
```
product_controller.dart   ← contains model + repo + usecase + controller
```

### Correct — one responsibility per file:
```
features/product/
├── domain/
│   ├── entities/
│   │   └── product_entity.dart
│   ├── repositories/
│   │   └── product_repository.dart
│   └── usecases/
│       ├── get_products_usecase.dart
│       ├── get_product_by_id_usecase.dart
│       └── create_product_usecase.dart    ← one usecase per file
│
├── data/
│   ├── models/
│   │   └── product_model.dart
│   ├── datasources/
│   │   ├── product_remote_datasource.dart
│   │   └── product_local_datasource.dart  ← remote and local are separate
│   └── repositories/
│       └── product_repository_impl.dart
│
└── presentation/
    ├── pages/
    │   └── products_page.dart
    ├── widgets/
    │   ├── product_card.dart              ← each widget in its own file
    │   ├── product_list.dart
    │   └── product_search_bar.dart
    └── controllers/
        ├── product_controller.dart
        └── product_binding.dart           ← binding is always a separate file
```

### Naming Conventions

| Type | Naming Pattern | Example |
|------|---------------|---------|
| Entity | `*_entity.dart` | `product_entity.dart` |
| Model | `*_model.dart` | `product_model.dart` |
| Repository (abstract) | `*_repository.dart` | `product_repository.dart` |
| Repository (impl) | `*_repository_impl.dart` | `product_repository_impl.dart` |
| UseCase | `*_usecase.dart` | `get_products_usecase.dart` |
| DataSource (abstract) | `*_datasource.dart` | `product_remote_datasource.dart` |
| Controller | `*_controller.dart` | `product_controller.dart` |
| Binding | `*_binding.dart` | `product_binding.dart` |
| Page / Screen | `*_page.dart` | `products_page.dart` |
| Widget | descriptive name | `product_card.dart` |
| Service | `*_service.dart` | `product_service.dart` |

### 7 pakges

dartz
hive
feezd
dio
cached_network_image
freezed
go_router


قم باستخدام flutter analyze لكي تتاكد من ان الكود يعمل بدون مشاكل