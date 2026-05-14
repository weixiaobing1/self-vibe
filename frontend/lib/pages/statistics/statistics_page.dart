import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../providers/statistics_provider.dart';
import '../../models/statistics.dart';
import '../../widgets/heatmap_grid.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stats = context.read<StatisticsProvider>();
      stats.loadWeeklyStats();
      stats.loadTrend(7);
      stats.loadHeatmap(_selectedYear, month: DateTime.now().month);
      stats.loadRetention();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学习统计')),
      body: Consumer<StatisticsProvider>(
        builder: (context, stats, _) {
          return RefreshIndicator(
            onRefresh: () async {
              await stats.loadWeeklyStats();
              await stats.loadTrend(7);
              await stats.loadHeatmap(_selectedYear, month: DateTime.now().month);
              await stats.loadRetention();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (stats.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: MaterialBanner(
                      backgroundColor: AppTheme.error.withValues(alpha: 0.1),
                      content: Text(stats.error!, style: TextStyle(color: AppTheme.error, fontSize: 13)),
                      leading: Icon(Icons.error_outline, color: AppTheme.error),
                      actions: [
                        TextButton(
                          onPressed: () {
                            stats.loadWeeklyStats();
                            stats.loadTrend(7);
                            stats.loadHeatmap(_selectedYear, month: DateTime.now().month);
                            stats.loadRetention();
                          },
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  ),
                _buildWeeklyCard(stats.weeklyStats),
                SizedBox(height: 16),
                HeatmapGrid(data: stats.heatmapData, currentStreak: stats.currentStreak),
                const SizedBox(height: 16),
                _buildRetentionCard(stats.retention),
                const SizedBox(height: 16),
                _buildYearSelector(stats),
                const SizedBox(height: 16),
                _buildTrendChart(stats.trend),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildYearSelector(StatisticsProvider stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: AppTheme.textSecondary),
          onPressed: () {
            setState(() {
              _selectedYear--;
              stats.loadHeatmap(_selectedYear, month: null);
            });
          },
        ),
        Text('$_selectedYear 年', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        IconButton(
          icon: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          onPressed: () {
            setState(() {
              _selectedYear++;
              stats.loadHeatmap(_selectedYear, month: null);
            });
          },
        ),
      ],
    );
  }

  Widget _buildWeeklyCard(WeeklyStats? weekly) {
    if (weekly == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('本周统计', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('笔记', '${weekly.totalNotes}', Icons.note_add_outlined),
                _statItem('复习', '${weekly.totalReviews}', Icons.replay_outlined),
                _statItem('面试题', '${weekly.totalInterviews}', Icons.quiz_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accentColor, size: 24),
        SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildRetentionCard(List<CategoryRetention> retention) {
    if (retention.isEmpty) return const SizedBox.shrink();

    final weakCategories = retention.where((r) => r.weakCount > 0).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('知识保留度', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            SizedBox(height: 16),
            ...retention.map((r) => _buildCategoryBar(r)),
            if (weakCategories.isNotEmpty) ...[
              SizedBox(height: 16),
              _buildWeakAreas(weakCategories),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBar(CategoryRetention r) {
    final color = r.avgScore > 70
        ? AppTheme.success
        : r.avgScore >= 40
            ? AppTheme.warning
            : AppTheme.error;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(r.category, style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
              Text('${r.avgScore.toStringAsFixed(0)}分 (${r.itemCount}项)',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
          SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: r.avgScore / 100,
              backgroundColor: AppTheme.surfaceColor,
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeakAreas(List<CategoryRetention> weak) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 18),
            SizedBox(width: 6),
            Text('薄弱领域', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.error, fontSize: 14)),
          ]),
          SizedBox(height: 8),
          ...weak.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${w.category}: ${w.weakCount}项需加强复习',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTrendChart(Trend? trend) {
    if (trend == null || trend.dates.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    for (int i = 0; i < trend.dates.length; i++) {
      spots.add(FlSpot(i.toDouble(), trend.noteCounts[i].toDouble()));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('学习趋势', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppTheme.textSecondary.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) => Text('${value.toInt()}',
                            style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= trend.dates.length) return const SizedBox.shrink();
                          final date = trend.dates[idx];
                          final short = date.length >= 5 ? date.substring(5) : date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(short, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (trend.dates.length - 1).toDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppTheme.accentColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.accentColor.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}