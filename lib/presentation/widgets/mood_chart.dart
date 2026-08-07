import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mood_tracker/constant/app_colors.dart';

import '../controllers/mood_controller.dart';

/// Bar chart visualization for the last seven days of mood logs.
///
/// Reads data from [MoodController] and shows tooltip notes when available.
///
/// Example:
/// ```dart
/// const SizedBox(height: 220, child: MoodChart())
/// ```
class MoodChart extends GetView<MoodController> {
  /// Creates the mood chart widget.
  const MoodChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final today = DateTime.now();
        final dates = List.generate(
          7,
          (index) {
            final date = today.subtract(Duration(days: 6 - index));
            return DateTime(date.year, date.month, date.day);
          },
        );

        return BarChart(
          BarChartData(
            minY: 0,
            maxY: 5,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              enabled: true,
              touchCallback: (event, response) {
                final index = response?.spot?.touchedBarGroupIndex;
                if (index == null || index < 0 || index >= dates.length) {
                  return;
                }
                controller.touchedChartDate.value = dates[index];
              },
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final entry = controller.entryForDate(dates[groupIndex]);
                  if (entry == null) {
                    return null;
                  }
                  return BarTooltipItem(
                    '${entry.emoji} ${entry.notes.isEmpty ? 'No note' : entry.notes}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= dates.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('E').format(dates[index]),
                        style: const TextStyle(
                          color: AppColors.inkSoft,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(dates.length, (index) {
              final entry = controller.entryForDate(dates[index]);
              final mood = entry?.mood ?? 0;
              final option = mood == 0 ? null : controller.moodOptionByValue(mood);

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: mood.toDouble(),
                    width: 18,
                    borderRadius: BorderRadius.circular(8),
                    color: option?.color ?? AppColors.line,
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 5,
                      color: AppColors.paperDim,
                    ),
                  ),
                ],
              );
            }),
          ),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      },
    );
  }
}
