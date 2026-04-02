import 'package:get/get.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';
import 'package:hive/hive.dart';
import '../../data/datasources/habit_stats_local_datasource.dart';
import '../../data/repositories/habit_stats_repository_impl.dart';
import '../../domain/usecases/get_overall_stats_usecase.dart';
import '../../domain/usecases/get_overall_trend_usecase.dart';
import '../../domain/usecases/get_individual_habit_trends_usecase.dart';
import '../../domain/usecases/get_today_habits_summary_usecase.dart';
import 'habitstats_controller.dart';

class HabitStatsBinding extends Bindings {
  @override
  void dependencies() {
    // Repository from Home feature is already registered by HabitBinding
    // but we need the interface reference
    final habitRepo = Get.find<HabitRepository>();

    // DataSource
    Get.lazyPut<HabitStatsLocalDataSource>(
      () => HabitStatsLocalDataSource(
        myBox: Hive.box(HabitStorage.boxName),
        habitRepository: habitRepo,
      ),
    );

    // Repository
    Get.lazyPut<HabitStatsRepositoryImpl>(
      () => HabitStatsRepositoryImpl(
        localDataSource: Get.find<HabitStatsLocalDataSource>(),
        getHistoryMap: () => {}, // Temporarily empty, should be handled better
      ),
    );

    // UseCases
    Get.lazyPut(
      () => GetOverallStatsUseCase(Get.find<HabitStatsRepositoryImpl>()),
    );
    Get.lazyPut(
      () => GetOverallTrendUseCase(Get.find<HabitStatsRepositoryImpl>()),
    );
    Get.lazyPut(
      () =>
          GetIndividualHabitTrendsUseCase(Get.find<HabitStatsRepositoryImpl>()),
    );
    Get.lazyPut(
      () => GetTodayHabitsSummaryUseCase(Get.find<HabitStatsRepositoryImpl>()),
    );

    // Controller
    Get.lazyPut(
      () => HabitStatsController(
        getOverallStatsUseCase: Get.find<GetOverallStatsUseCase>(),
        getOverallTrendUseCase: Get.find<GetOverallTrendUseCase>(),
        getIndividualHabitTrendsUseCase:
            Get.find<GetIndividualHabitTrendsUseCase>(),
        getTodayHabitsSummaryUseCase: Get.find<GetTodayHabitsSummaryUseCase>(),
      ),
    );
  }
}
