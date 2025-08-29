import 'package:get/get.dart';

class TrendChartState extends GetxController {
  final RxBool isweekly = true.obs;
  final RxBool showIndividualProgress = true.obs;
  final RxBool isAll = true.obs;
  final RxInt value = 7.obs; 



  void toggleView() => showIndividualProgress.toggle();

  void toggleWeekly() => value.value = 7;
  void toggleMonthly() => value.value = 30;

  void toggle() {
    isweekly.value = !isweekly.value;
    isweekly.value ? toggleWeekly() : toggleMonthly();
    }
  
  void weeklytoggle() {
    isweekly.value = !isweekly.value;

}
}
