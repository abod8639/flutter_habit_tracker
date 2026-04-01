# Architecture Reference — Clean Architecture in Flutter

## Layer Rules

### 1. Domain Layer (Core of the app)

- Has **zero dependencies** on any other layer.
- Contains no Flutter imports — pure Dart only.

**Entity:**

```dart
// lib/features/product/domain/entities/product_entity.dart
class ProductEntity {
  final int id;
  final String name;
  final double price;
  final String categoryName;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryName,
  });
}
```

**Repository Interface (Abstract):**

```dart
// lib/features/product/domain/repositories/product_repository.dart
abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();
  Future<Either<Failure, ProductEntity>> getProductById(int id);
  Future<Either<Failure, void>> createProduct(ProductEntity product);
}
```

**UseCase — Single Responsibility:**

```dart
// lib/features/product/domain/usecases/get_products_usecase.dart
class GetProductsUseCase {
  final ProductRepository repository;
  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call() =>
      repository.getProducts();
}
```

---

### 2. Data Layer

**Model (DTO with JSON serialization):**

```dart
// lib/features/product/data/models/product_model.dart
class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.categoryName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'],
    name: json['name'],
    price: (json['price'] as num).toDouble(),
    categoryName: json['category']['name'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
  };
}
```

**Remote DataSource:**

```dart
// lib/features/product/data/datasources/product_remote_datasource.dart
abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ProductService service;
  ProductRemoteDataSourceImpl(this.service);

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await service.getProducts();
    return (response.data['data'] as List)
        .map((e) => ProductModel.fromJson(e))
        .toList();
  }
}
```

**Repository Implementation:**

```dart
// lib/features/product/data/repositories/product_repository_impl.dart
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final CacheService cacheService;

  ProductRepositoryImpl(this.remoteDataSource, this.cacheService);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    try {
      // Try cache first
      final cached = await cacheService.getProducts();
      if (cached != null) return Right(cached);

      // Fetch from API
      final products = await remoteDataSource.getProducts();
      await cacheService.saveProducts(products);
      return Right(products);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    }
  }
}
```

---

### 3. Presentation Layer

**Controller:**

```dart
// lib/features/product/presentation/controllers/product_controller.dart
class ProductController extends GetxController {
  final GetProductsUseCase getProductsUseCase;

  ProductController(this.getProductsUseCase);

  final RxList<ProductEntity> products = <ProductEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await getProductsUseCase();
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (data) => products.assignAll(data),
    );

    isLoading.value = false;
  }
}
```

**Binding (Dependency Injection):**

```dart
// lib/features/product/presentation/controllers/product_binding.dart
class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductService());
    Get.lazyPut<ProductRemoteDataSource>(
        () => ProductRemoteDataSourceImpl(Get.find()));
    Get.lazyPut<ProductRepository>(
        () => ProductRepositoryImpl(Get.find(), Get.find()));
    Get.lazyPut(() => GetProductsUseCase(Get.find()));
    Get.lazyPut(() => ProductController(Get.find()));
  }
}
```

---

## Error Handling

```dart
// lib/core/error/failures.dart
abstract class Failure {
  final String message;
  const Failure({required this.message});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}
```
