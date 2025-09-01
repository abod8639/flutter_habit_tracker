import 'package:get/get.dart';
import 'package:habit_tracker/view/HabitStatsPage/data/getHabitProgressionData.dart';

class TrendChartState extends GetxController {
  // تصحيح: استخدام أسماء متغيرات أوضح وأكثر وصفية
  final RxBool isWeeklyView = true.obs;
  final RxBool showIndividualProgress = true.obs;
  final RxBool showAllHabits = true.obs;
  final RxInt daysPeriod = 7.obs;

  final RxList<String> habitNames = RxList<String>();

  @override
  void onInit() {
    super.onInit();
    updateHabitNames();
    
    // إضافة listeners للتحديث التلقائي
    ever(isWeeklyView, (_) => updateHabitNames());
    ever(showIndividualProgress, (_) => updateHabitNames());
  }

  void updateHabitNames() {
    if (showIndividualProgress.value) {
      final Map<String, dynamic> progressionData = isWeeklyView.value
          ? getLast7DaysHabitProgression()
          : getLast30DaysHabitProgression();
      habitNames.value = progressionData.keys.toList();
    } else {
      habitNames.value = ['Overall'];
    }
  }

  void toggleIndividualView() {
    showIndividualProgress.toggle();
    updateHabitNames();
  }

  void setWeeklyView() {
    isWeeklyView.value = true;
    daysPeriod.value = 7;
    updateHabitNames();
  }

  void setMonthlyView() {
    isWeeklyView.value = false;
    daysPeriod.value = 30;
    updateHabitNames();
  }

  void togglePeriod() {
    if (isWeeklyView.value) {
      setMonthlyView();
    } else {
      setWeeklyView();
    }
  }

  void toggleShowAllHabits() {
    showAllHabits.toggle();
  }
}
