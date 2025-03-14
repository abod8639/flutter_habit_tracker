import 'package:habit_tracker/models/date_time.dart';
import 'package:hive/hive.dart';

final myBox = Hive.box("Habit_db");

class Habitdb  {
  List todaysHabitList = [];
  Map<DateTime, int> heatmapDateSet = {};

  void createDefaultData() {
    todaysHabitList = [
      ["Read a Book", false],
      ["Learn Something New", false],
      ["Relaxation", false],
    ];
    myBox.put("START_DAY", todaysDateFormatted());
  }

  void loadData() {
    if (myBox.get("TODOLIST") != null) {
      todaysHabitList = myBox.get("TODOLIST");
    }
    loadHeatmap();
  }

  void updateData() {
    // تخزين القائمة الحالية
    myBox.put("TODOLIST", todaysHabitList);
    
    // تخزين قائمة اليوم بالتاريخ الحالي
    myBox.put(todaysDateFormatted(), todaysHabitList);
    
    // حساب نسبة الإنجاز ورسم الخريطة الحرارية
    habitCalculate();
    loadHeatmap();
  }

  void habitCalculate() {
    int count = 0;
    for (int i = 0; i < todaysHabitList.length; i++) {
      if (todaysHabitList[i][1] == true) {
        count++;
      }
    }
    
    // حساب النسبة المئوية للإنجاز
    String date = todaysHabitList.isEmpty
        ? "0.0"
        : (count / todaysHabitList.length).toStringAsFixed(1);
    
    // تخزين النسبة مع مفتاح يحتوي على تاريخ اليوم
    myBox.put("TODAY_HABIT${todaysDateFormatted()}", date);
  }
 
  List<Map<String, dynamic>> getIncompleteHabits() {
    return todaysHabitList
        .where((habit) => habit[1] == false) // فلترة العادات غير المكتملة
        .map((habit) => {"name": habit[0], "completed": habit[1]}) // تحويلها إلى خريطة
        .toList(); // تحويل النتيجة إلى قائمة
  }
  List<Map<String, dynamic>> getCompletedHabits() {
    return todaysHabitList
        .where((habit) => habit[1] == true) // فلترة العادات غير المكتملة
        .map((habit) => {"name": habit[0], "completed": habit[1]}) // تحويلها إلى خريطة
        .toList(); // تحويل النتيجة إلى قائمة
  }



  void loadHeatmap() {
    try {
      // الحصول على تاريخ البداية
      String? startDateStr = myBox.get("START_DAY");
      
      // إذا لم يكن موجودًا، قم بإنشاء البيانات الافتراضية
      if (startDateStr == null) {
        createDefaultData();
        startDateStr = myBox.get("START_DAY");
        
        // إذا استمرت المشكلة، استخدم تاريخ اليوم
        if (startDateStr == null) {
          startDateStr = todaysDateFormatted();
          myBox.put("START_DAY", startDateStr);
        }
      }
      
      // تحويل النص إلى كائن DateTime
      DateTime startDate;
      try {
        startDate = createDateTimeObject(startDateStr);
      } catch (e) {
        // في حالة حدوث خطأ في التحويل، استخدم تاريخ اليوم
        startDateStr = todaysDateFormatted();
        myBox.put("START_DAY", startDateStr);
        startDate = DateTime.now();
      }
      
      // حساب عدد الأيام بين تاريخ البداية واليوم
      int daysInBetween = DateTime.now().difference(startDate).inDays;
      
      // تفريغ مجموعة البيانات قبل إعادة تحميلها
      heatmapDateSet = {};

      // التحقق مما إذا كان اليوم قد تغير
      String lastSavedDate = myBox.get("LAST_SAVED_DATE", defaultValue: "");
      String todayDate = todaysDateFormatted();

      if (lastSavedDate != todayDate) {
        // إعادة تعيين حالة العادات إلى false
        for (int i = 0; i < todaysHabitList.length; i++) {
          todaysHabitList[i][1] = false;
        }
        // حفظ تاريخ اليوم كتاريخ آخر حفظ
        myBox.put("LAST_SAVED_DATE", todayDate);
      }

      // إنشاء بيانات لكل يوم
      for (int i = 0; i < daysInBetween + 1; i++) {
        DateTime currentDate = startDate.add(Duration(days: i));
        String yyyymmdd = convertDateTimeToString(currentDate);
        
        // الحصول على قيمة الإنجاز لهذا اليوم
        String? habitStrength = myBox.get("TODAY_HABIT$yyyymmdd");
        double strength = 0.0;

        
        // محاولة تحويل النص إلى رقم
        if (habitStrength != null) {
          try {
            strength = double.parse(habitStrength);
          } catch (e) {
            // في حالة حدوث خطأ في التحويل
            strength = 0.0;
          }
        }
        
        // إضافة البيانات إلى المجموعة
        final percentForDate = <DateTime, int>{
          DateTime(currentDate.year, currentDate.month, currentDate.day): 
              (strength * 10).toInt()
        };
        
        heatmapDateSet.addEntries(percentForDate.entries);
      }
    } catch (e) {
      // في حالة حدوث أي خطأ، إعادة تعيين البيانات
      print("Error in loadHeatmap: $e");
      heatmapDateSet = {};
    }
  }
}
