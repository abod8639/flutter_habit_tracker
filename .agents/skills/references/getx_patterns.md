# GetX Patterns Reference

## Dependency Injection

### Always use `Get.lazyPut` inside Bindings:

```dart
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthService());
    Get.lazyPut<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(Get.find()));
    Get.lazyPut<AuthRepository>(
        () => AuthRepositoryImpl(Get.find()));
    Get.lazyPut(() => LoginUseCase(Get.find()));
    Get.lazyPut(() => AuthController(Get.find(), Get.find()));
  }
}
```

### Use `Get.put` with `permanent: true` for app-wide services:

```dart
// In main.dart or AppBinding
Get.put(StorageService(), permanent: true);
Get.put(AuthController(Get.find()), permanent: true);
```

---

## Routing

### Define routes as constants:

```dart
// lib/core/constants/app_routes.dart
abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const products = '/products';
  static const productDetail = '/products/detail';
}
```

### Register pages with Bindings:

```dart
// lib/core/constants/app_pages.dart
abstract class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.products,
      page: () => const ProductsPage(),
      binding: ProductBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailPage(),
      binding: ProductBinding(),
    ),
  ];
}
```

### Navigation:

```dart
// Push
Get.toNamed(AppRoutes.products);
Get.toNamed(AppRoutes.productDetail, arguments: {'id': product.id});

// Clear stack (e.g. after logout)
Get.offAllNamed(AppRoutes.login);

// Receive arguments
final args = Get.arguments as Map<String, dynamic>;
final id = args['id'] as int;
```

---

## State Patterns

### Pattern 1: Loading / Success / Error State

```dart
class ProductController extends GetxController {
  final RxList<ProductEntity> products = <ProductEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> fetchProducts() async {
    isLoading.value = true;
    error.value = '';

    final result = await getProductsUseCase();
    result.fold(
      (failure) => error.value = failure.message,
      (data) => products.assignAll(data),
    );

    isLoading.value = false;
  }
}

// In Widget
Obx(() {
  if (controller.isLoading.value) return const LoadingWidget();
  if (controller.error.isNotEmpty) return ErrorWidget(controller.error.value);
  return ProductList(products: controller.products);
})
```

### Pattern 2: Simple Reactive Variables

```dart
final RxList<ProductEntity> items = <ProductEntity>[].obs;
final RxBool isLoading = false.obs;
final RxString searchQuery = ''.obs;
```

---

## Workers (Reactive Listeners)

```dart
@override
void onInit() {
  super.onInit();

  // Fires every time value changes
  ever(isLoading, (loading) {
    if (!loading && error.isNotEmpty) {
      Get.snackbar('Error', error.value);
    }
  });

  // Fires only on the first change
  once(products, (_) => print('Products loaded for the first time'));

  // Fires after the value stops changing for the given duration
  debounce(searchQuery, (_) => search(), time: const Duration(milliseconds: 500));
}
```

---

## Snackbar, Dialog & BottomSheet

```dart
// Snackbar
Get.snackbar(
  'Success',
  'Product saved successfully',
  snackPosition: SnackPosition.BOTTOM,
  backgroundColor: AppColors.success,
);

// Dialog
Get.defaultDialog(
  title: 'Confirm Delete',
  middleText: 'Are you sure you want to delete this item?',
  onConfirm: () => controller.deleteProduct(id),
  onCancel: Get.back,
);

// BottomSheet
Get.bottomSheet(
  const DeleteConfirmSheet(),
  isScrollControlled: true,
);
```
