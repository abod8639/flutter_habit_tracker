import 'package:get/get.dart';

class TrendChartState extends GetxController {
  final RxBool isweekly = true.obs;
  final RxBool showIndividualProgress = true.obs;
  final RxInt days = 30.obs;

  void toggleView() => showIndividualProgress.toggle();

  void toggle() {
    isweekly.value = !isweekly.value;
    if (isweekly.value) {
      toggleWeekly();
    } else {
      toggleMonthly();
    }
  }

  void toggleWeekly() => days.value = 7;
  void toggleMonthly() => days.value = 30;
}
