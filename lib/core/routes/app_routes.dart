import 'package:get/get.dart';
import 'package:habit_tracker/features/categorys/presentation/controllers/plan_generator_controller.dart';
import 'package:habit_tracker/features/categorys/presentation/views/category_selection_screen.dart';
import 'package:habit_tracker/features/categorys/presentation/views/plan_result_screen.dart';
import 'package:habit_tracker/features/categorys/presentation/views/questionnaire_screen.dart';

// ── Route name constants ──────────────────────────────────────────────────────
abstract class AppRoutes {
  static const categorySelection = '/plan-category';
  static const questionnaire = '/plan-questionnaire';
  static const result = '/plan-result';
}

// ── GetPages to add to your GetMaterialApp pages list ────────────────────────
final appPages = [
  GetPage(
    name: AppRoutes.categorySelection,
    page: () => const CategorySelectionScreen(),
    binding: BindingsBuilder(() {
      Get.lazyPut<PlanGeneratorController>(
        () => PlanGeneratorController(),
        fenix: true,
      );
    }),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: AppRoutes.questionnaire,
    page: () => const QuestionnaireScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: AppRoutes.result,
    page: () => const PlanResultScreen(),
    transition: Transition.cupertino,
  ),
];
