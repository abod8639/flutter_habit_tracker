import 'dart:math' as Math;
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/controller.dart'; // استيراد ملف controller

class HabitStatsPage extends StatelessWidget {
  final HabitController habitController = Get.find<HabitController>();

  HabitStatsPage({super.key});

  // إضافة دوال مساعدة لفصل العمليات الحسابية
  Map<String, dynamic> _calculateStats(HabitController controller) {
    final int totalHabits = controller.db.todaysHabitList.length;
    final int completedHabits =
        controller.db.todaysHabitList.where((habit) => habit[1] == true).length;
    final double completionRate =
        totalHabits > 0 ? (completedHabits / totalHabits) * 100 : 0;

    return {
      'totalHabits': totalHabits,
      'completedHabits': completedHabits,
      'completionRate': completionRate,
    };
  }

  List<Map<String, dynamic>> _prepareChartData(HabitController controller) {
    List<Map<String, dynamic>> chartData = [];
    for (int i = 0; i < controller.db.todaysHabitList.length; i++) {
      chartData.add({
        'habit': controller.db.todaysHabitList[i][0],
        'completed': controller.db.todaysHabitList[i][1],
        'index': i,
      });
    }
    return chartData;
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event.isKeyPressed(LogicalKeyboardKey.escape) ||
            event.isKeyPressed(LogicalKeyboardKey.backspace)) {
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Habit grow'), //habit grow
          centerTitle: true,
        ),
        body: GetBuilder<HabitController>(
          builder: (controller) {
            // حساب الإحصائيات من البيانات
            final stats = _calculateStats(controller);
            final int totalHabits = stats['totalHabits'];
            final int completedHabits = stats['completedHabits'];
            final double completionRate = stats['completionRate'];

            // تحضير بيانات للرسم البياني
            final List<Map<String, dynamic>> chartData = _prepareChartData(
              controller,
            );

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عرض بطاقة ملخص الإحصائيات
                    statsCard(totalHabits, completedHabits, completionRate),

                    const SizedBox(height: 24),

                    // عرض الرسوم البيانية بناءً على نوع الجهاز
                    controller.isDesktop(context)
                        ? Card(
                          elevation: 4,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 350,
                                  padding: const EdgeInsets.all(16.0),
                                  child: Lgraph(chartData: chartData),
                                ),
                              ),
                              Expanded(
                                child: Cgraph(
                                  completedHabits: completedHabits,
                                  totalHabits: totalHabits,
                                ),
                              ),
                            ],
                          ),
                        )
                        : Column(
                          children: [
                            Card(
                              elevation: 4,
                              child: Container(
                                height: 350,
                                padding: const EdgeInsets.all(16.0),
                                child: Lgraph(chartData: chartData),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Card(
                              elevation: 4,
                              child: SizedBox(
                                height: 350,
                                child: Cgraph(
                                  completedHabits: completedHabits,
                                  totalHabits: totalHabits,
                                ),
                              ),
                            ),
                          ],
                        ),

                    const SizedBox(height: 24),

                    // عرض قائمة العادات وحالتها
                    if (totalHabits > 0)
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Completed Habits',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: chartData.length > 5 ? 350 : null,
                                child: Tgraph(chartData: chartData),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // بطاقة النص التحفيزي
                    Center(
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "You are too far away to explore the whole universe.",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Card statsCard(int totalHabits, int completedHabits, double completionRate) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Habits Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: statItem('Total', totalHabits.toString())),
                Expanded(
                  child: statItem('Completed', completedHabits.toString()),
                ),
                Expanded(
                  child: statItem(
                    'Rate',
                    '${completionRate.toStringAsFixed(1)}%',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget statItem(String title, String value) {
    return Column(
      children: [
        Builder(
          builder: (context) {
            return Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: 16,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}

class Tgraph extends StatelessWidget {
  const Tgraph({super.key, required this.chartData});

  final List<Map<String, dynamic>> chartData;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics:
          chartData.length > 5
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: chartData.length,
      itemBuilder: (context, index) {
        final habit = chartData[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor:
                habit['completed']
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.error,
            child: Text(
              '${index + 1}',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
          title: Text(
            habit['habit'],
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
          ),
          trailing: Icon(
            habit['completed'] ? Icons.check_circle : Icons.cancel,
            color:
                habit['completed']
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.error,
          ),
        );
      },
    );
  }
}
//--------------------------------------
class Cgraph extends StatelessWidget {
  const Cgraph({
    super.key,
    required this.completedHabits,
    required this.totalHabits,
  });

  final int completedHabits;
  final int totalHabits;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          // const Text(
          //   'Completion Rate Of Habit',
          //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          // ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child:
                totalHabits > 0
                    ? PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 35,
                        sections: [
                          PieChartSectionData(
                            value: completedHabits.toDouble(),
                            title: 'Completed',
                            color: Theme.of(context).primaryColor,
                            radius: 100,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: (totalHabits - completedHabits).toDouble(),
                            title: 'Incomplete',
                            color: Theme.of(context).colorScheme.error,
                            radius: 100,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                    : const Center(
                      child: Expanded(
                        child: Text(
                          'No habits to display',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
//------------------------------------------
class Lgraph extends StatelessWidget {
  const Lgraph({super.key, required this.chartData});
  final List<Map<String, dynamic>> chartData;

  @override
  Widget build(BuildContext context) {
    final HabitController cont = Get.find<HabitController>();

    // تعامل مع حالة عدم وجود بيانات
    if (chartData.isEmpty) {
      return const Center(
        child: Text('No habit data available', style: TextStyle(fontSize: 16)),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        minY: 0,
        maxY: cont.dayCount > 0 ? cont.dayCount.toDouble() : 5.0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            direction: TooltipDirection.auto,
            getTooltipColor: (group) {
              return Theme.of(context).primaryColor;
            },
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                chartData[groupIndex]['habit'],
                TextStyle(color: Theme.of(context).colorScheme.onSecondary),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  "${value.toInt()}",
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < chartData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${value.toInt() + 1}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          horizontalInterval: 1,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        barGroups: chartData.asMap().entries.map((entry) {
          final int index = entry.key;
          final Map<String, dynamic> habit = entry.value;
          
          // استخدام قيمة ديناميكية لارتفاع الأعمدة
          final double maxValue = cont.dayCount > 0 ? cont.dayCount.toDouble() : 5.0;
          
          // حساب القيمة بناءً على عدد الأيام المتتالية التي لم يتم فيها إنجاز العادة
          double barValue;
          if (habit['completed']) {
            barValue = maxValue;
          } else {
            // التحقق من وجود قيمة للأيام المتتالية غير المنجزة
            int consecutiveMisses = habit['consecutiveMisses'] ?? 1;
            
            // معامل التناقص - يمكن تعديله حسب الحاجة (مثلاً 0.8 يعني تناقص بنسبة 20% كل يوم)
            double decayFactor = 0.8;
            
            // حساب القيمة المتناقصة تدريجياً
            barValue = maxValue * Math.pow(decayFactor, consecutiveMisses).toDouble();
            
            // تعيين حد أدنى للقيمة لتجنب الأشرطة الصغيرة جداً
            barValue = max(barValue, maxValue * 0.1);
          }

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                
                toY: barValue,
                color: habit['completed']
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.error,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}