import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/statistics.dart';

class HeatmapGrid extends StatelessWidget {
  final List<DailyStats> data;
  final int currentStreak;

  const HeatmapGrid({super.key, required this.data, this.currentStreak = 0});

  Color _colorForActivity(int notes, int reviews, int interviews, int duration) {
    final total = notes + reviews + interviews + (duration > 0 ? 1 : 0);
    if (total == 0) return AppTheme.surfaceColor;
    if (total <= 2) return AppTheme.accentColor.withValues(alpha: 0.2);
    if (total <= 5) return AppTheme.accentColor.withValues(alpha: 0.5);
    if (total <= 9) return AppTheme.accentColor.withValues(alpha: 0.75);
    return AppTheme.accentColor;
  }

  String _tooltipForDay(DailyStats d) {
    final total = d.noteCount + d.reviewCount + d.interviewCount + (d.studyDuration > 0 ? 1 : 0);
    if (total == 0) return '${d.date}: 无活动';
    final parts = <String>[];
    if (d.noteCount > 0) parts.add('${d.noteCount}条笔记');
    if (d.reviewCount > 0) parts.add('${d.reviewCount}次复习');
    if (d.interviewCount > 0) parts.add('${d.interviewCount}道面试题');
    if (d.studyDuration > 0) parts.add('${d.studyDuration ~/ 60}分钟学习');
    return '${d.date}: ${parts.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final firstDate = DateTime.tryParse(data.first.date) ?? DateTime.now();
    final lastDate = DateTime.tryParse(data.last.date) ?? DateTime.now();

    // Calculate the first Monday on or before the first date
    final gridStart = firstDate.subtract(Duration(days: firstDate.weekday - 1));
    final totalDays = lastDate.difference(gridStart).inDays + 1;
    final totalWeeks = (totalDays / 7).ceil();

    final cellSize = (MediaQuery.of(context).size.width - 32 - (totalWeeks * 3)) / totalWeeks;
    final constrainedSize = cellSize.clamp(10.0, 20.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('学习热力图', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const Spacer(),
                if (currentStreak > 0) ...[
                  Icon(Icons.local_fire_department, color: AppTheme.warning, size: 18),
                  SizedBox(width: 4),
                  Text('连续 $currentStreak 天', style: TextStyle(color: AppTheme.warning, fontSize: 13)),
                ],
              ],
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day labels
                  Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Column(
                          children: [
                            SizedBox(height: 14),
                            Text('一', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                            SizedBox(height: 12),
                            Text('三', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                            SizedBox(height: 12),
                            Text('五', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      for (int w = 0; w < totalWeeks; w++)
                        Padding(
                          padding: const EdgeInsets.only(left: 3),
                          child: Column(
                            children: [
                              for (int d = 0; d < 7; d++)
                                _buildCell(gridStart, w, d, constrainedSize, totalDays),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Legend
                  Row(
                    children: [
                      Text('少', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                      ...List.generate(5, (i) {
                        final opacity = i == 0 ? 0.2 : i == 1 ? 0.5 : i == 2 ? 0.75 : 1.0;
                        return Container(
                          margin: const EdgeInsets.only(left: 3),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: i == 0 ? AppTheme.surfaceColor : AppTheme.accentColor.withValues(alpha: opacity),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                      SizedBox(width: 4),
                      Text('多', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(DateTime gridStart, int week, int day, double size, int totalDays) {
    final cellDate = gridStart.add(Duration(days: week * 7 + day));
    final dayIndex = week * 7 + day;

    if (dayIndex >= totalDays) {
      return Container(
        width: size,
        height: size,
        margin: const EdgeInsets.only(top: 2, left: 3),
      );
    }

    DailyStats? match;
    for (final d in data) {
      if (d.date == cellDate.toIso8601String().substring(0, 10)) {
        match = d;
        break;
      }
    }

    final color = match != null
        ? _colorForActivity(match.noteCount, match.reviewCount, match.interviewCount, match.studyDuration)
        : AppTheme.surfaceColor;

    return Tooltip(
      message: match != null ? _tooltipForDay(match) : '${cellDate.toIso8601String().substring(0, 10)}: 无活动',
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.only(top: 2, left: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}