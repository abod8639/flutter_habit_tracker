import 'package:get/get.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/data/habit_storage.dart';
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
    // DataSource
    Get.lazyPut<HabitStatsLocalDataSource>(
      () => HabitStatsLocalDataSource(
        myBox: Hive.box(HabitStorage.boxName),
        habitRepository: Get.find<HabitController>().db,
      ),
    );

    // Repository
    Get.lazyPut<HabitStatsRepositoryImpl>(
      () => HabitStatsRepositoryImpl(
        localDataSource: Get.find<HabitStatsLocalDataSource>(),
        getHistoryMap: () => Get.find<HabitController>().habitHistoryMap.value,
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
