# Riverpod Patterns Reference

> ⚠️ **Senior Note:** This project uses **GetX** as its primary state management solution.
> Riverpod is documented here for reference and future consideration only.
> Do NOT mix Riverpod and GetX in the same feature — pick one per feature and stay consistent.
> If you are considering migrating to Riverpod, discuss the tradeoffs with the team first.

---

## Why Riverpod Over Provider?

| Feature                    | Provider | Riverpod  |
| -------------------------- | -------- | --------- |
| Compile-time safety        | ❌       | ✅        |
| No `BuildContext` required | ❌       | ✅        |
| Testability                | Medium   | Excellent |
| Auto-dispose               | Manual   | Built-in  |
| Combining providers        | Complex  | Simple    |

---

## Setup

```dart
// main.dart
void main() {
  runApp(
    const ProviderScope(  // wraps the entire app
      child: StrongerMusclesApp(),
    ),
  );
}
```

---

## Core Provider Types

### 1. `Provider` — Read-only synchronous value

```dart
// lib/features/product/presentation/providers/product_provider.dart
final currencyProvider = Provider<String>((ref) => 'USD');

// Usage in Widget
final currency = ref.watch(currencyProvider);
```

---

### 2. `StateProvider` — Simple mutable state

Use for simple values like filters, toggles, counters.

```dart
final selectedCategoryProvider = StateProvider<int?>((ref) => null);

// In Widget
ref.read(selectedCategoryProvider.notifier).state = categoryId;
final selected = ref.watch(selectedCategoryProvider);
```

---

### 3. `FutureProvider` — Async data fetching

```dart
// lib/features/product/presentation/providers/products_future_provider.dart
final productsProvider = FutureProvider.autoDispose<List<ProductEntity>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getProducts();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

// In Widget — handles loading/error/data automatically
ref.watch(productsProvider).when(
  loading: () => const LoadingWidget(),
  error: (e, _) => ErrorWidget(message: e.toString()),
  data: (products) => ProductList(products: products),
);
```

---

### 4. `StreamProvider` — Real-time streams

```dart
final stockUpdatesProvider = StreamProvider.autoDispose<List<StockEntity>>((ref) {
  return ref.watch(stockServiceProvider).watchStockUpdates();
});
```

---

### 5. `NotifierProvider` — Complex mutable state (recommended over StateNotifier)

```dart
// lib/features/product/domain/notifiers/product_notifier.dart
class ProductNotifier extends Notifier<ProductState> {
  @override
  ProductState build() => const ProductState.initial();

  Future<void> fetchProducts() async {
    state = const ProductState.loading();

    final result = await ref.read(getProductsUseCaseProvider).call();
    state = result.fold(
      (failure) => ProductState.error(failure.message),
      (products) => ProductState.success(products),
    );
  }

  Future<void> deleteProduct(int id) async {
    final result = await ref.read(deleteProductUseCaseProvider).call(id);
    result.fold(
      (failure) => state = ProductState.error(failure.message),
      (_) => fetchProducts(),
    );
  }
}

final productNotifierProvider =
    NotifierProvider<ProductNotifier, ProductState>(ProductNotifier.new);
```

---

### 6. `AsyncNotifierProvider` — Async notifier with built-in loading/error

```dart
class ProductAsyncNotifier extends AsyncNotifier<List<ProductEntity>> {
  @override
  Future<List<ProductEntity>> build() => _fetchProducts();

  Future<List<ProductEntity>> _fetchProducts() async {
    final result = await ref.read(getProductsUseCaseProvider).call();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (products) => products,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchProducts);
  }
}

final productAsyncProvider =
    AsyncNotifierProvider<ProductAsyncNotifier, List<ProductEntity>>(
        ProductAsyncNotifier.new);
```

---

## State Modeling with Sealed Classes

Always model state explicitly — avoid raw booleans like `isLoading`.

```dart
// lib/features/product/domain/states/product_state.dart
sealed class ProductState {
  const ProductState();
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductSuccess extends ProductState {
  final List<ProductEntity> products;
  const ProductSuccess(this.products);
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
}
```

```dart
// In Widget — exhaustive pattern matching (Dart 3+)
switch (state) {
  ProductInitial() => const SizedBox.shrink(),
  ProductLoading() => const LoadingWidget(),
  ProductSuccess(:final products) => ProductList(products: products),
  ProductError(:final message) => ErrorWidget(message: message),
}
```

---

## Dependency Injection with Riverpod

Wire your Clean Architecture layers using providers — this replaces GetX Bindings.

```dart
// lib/features/product/presentation/providers/product_di_providers.dart

// Service
final productServiceProvider = Provider<ProductService>((ref) => ProductService());

// DataSource
final productRemoteDataSourceProvider =
    Provider<ProductRemoteDataSource>((ref) =>
        ProductRemoteDataSourceImpl(ref.watch(productServiceProvider)));

// Repository
final productRepositoryProvider =
    Provider<ProductRepository>((ref) =>
        ProductRepositoryImpl(
          ref.watch(productRemoteDataSourceProvider),
          ref.watch(cacheServiceProvider),
        ));

// UseCases
final getProductsUseCaseProvider =
    Provider<GetProductsUseCase>((ref) =>
        GetProductsUseCase(ref.watch(productRepositoryProvider)));

final deleteProductUseCaseProvider =
    Provider<DeleteProductUseCase>((ref) =>
        DeleteProductUseCase(ref.watch(productRepositoryProvider)));
```

---

## `ref` Usage Rules

| Method             | When to Use                                                                |
| ------------------ | -------------------------------------------------------------------------- |
| `ref.watch()`      | Inside `build()` or `Notifier.build()` — subscribes and rebuilds on change |
| `ref.read()`       | Inside callbacks / methods — reads once without subscribing                |
| `ref.listen()`     | Side effects (navigation, snackbars) — reacts to changes                   |
| `ref.invalidate()` | Force re-fetch / reset a provider                                          |

```dart
// ✅ ref.watch in build — reactive
final products = ref.watch(productNotifierProvider);

// ✅ ref.read in button callback — one-time action
onPressed: () => ref.read(productNotifierProvider.notifier).fetchProducts()

// ✅ ref.listen for side effects — navigation, snackbars
ref.listen(productNotifierProvider, (previous, next) {
  if (next is ProductError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(next.message)),
    );
  }
});

// ❌ NEVER use ref.watch inside a callback
onPressed: () => ref.watch(someProvider) // breaks reactivity model
```

---

## `autoDispose` — When to Use

Always use `.autoDispose` unless the provider must survive navigation:

```dart
// ✅ autoDispose — disposed when no longer listened to
final searchResultsProvider = FutureProvider.autoDispose<List<ProductEntity>>((ref) async {
  ...
});

// ✅ Keep alive explicitly when needed
final persistentProvider = Provider.autoDispose<SomeService>((ref) {
  ref.keepAlive(); // survives screen pop
  return SomeService();
});
```

---

## Widget Integration

Use `ConsumerWidget` instead of `StatelessWidget` to access `ref`:

```dart
// lib/features/product/presentation/pages/products_page.dart
class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: switch (state) {
        ProductLoading() => const LoadingWidget(),
        ProductSuccess(:final products) => ProductList(products: products),
        ProductError(:final message) => ErrorWidget(message: message),
        ProductInitial() => const SizedBox.shrink(),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ref.read(productNotifierProvider.notifier).fetchProducts(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

Use `ConsumerStatefulWidget` only when `StatefulWidget` lifecycle methods are needed:

```dart
class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  @override
  void initState() {
    super.initState();
    // Safe to call ref here
    Future.microtask(() =>
        ref.read(productNotifierProvider.notifier).fetchProducts());
  }

  @override
  Widget build(BuildContext context) { ... }
}
```

---

## Testing with Riverpod

Riverpod's biggest advantage over GetX is **first-class testability** — no context, no singletons.

```dart
// test/features/product/product_notifier_test.dart
void main() {
  test('fetchProducts emits success state', () async {
    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(MockProductRepository()),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(productNotifierProvider.notifier);
    await notifier.fetchProducts();

    expect(
      container.read(productNotifierProvider),
      isA<ProductSuccess>(),
    );
  });
}
```

---

## File Structure for Riverpod Features

```
features/product/
├── domain/
│   ├── entities/product_entity.dart
│   ├── repositories/product_repository.dart
│   ├── usecases/
│   │   ├── get_products_usecase.dart
│   │   └── delete_product_usecase.dart
│   └── states/
│       └── product_state.dart           ← sealed state classes
│
├── data/
│   ├── models/product_model.dart
│   ├── datasources/product_remote_datasource.dart
│   └── repositories/product_repository_impl.dart
│
└── presentation/
    ├── providers/
    │   ├── product_di_providers.dart    ← DI wiring (replaces Bindings)
    │   └── product_notifier.dart        ← NotifierProvider logic
    ├── pages/products_page.dart
    └── widgets/
        ├── product_card.dart
        └── product_list.dart
```
