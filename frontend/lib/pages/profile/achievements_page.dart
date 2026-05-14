import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/achievement.dart';

class AchievementsPage extends StatelessWidget {
  final SummaryData data;
  const AchievementsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievements.where((a) => a.condition(data)).toList();
    final locked = achievements.where((a) => !a.condition(data)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('学习成就')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem('🏆', '${unlocked.length}/${achievements.length}', '徽章'),
                  _summaryItem('📝', '${data.totalNotes}', '笔记'),
                  _summaryItem('🔄', '${data.totalReviews}', '复习'),
                  _summaryItem('⏱️', '${data.totalStudyHours}h', '学习'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('已解锁 (${unlocked.length})', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          ...unlocked.map((a) => _badgeCard(a, true)),
          const SizedBox(height: 16),
          Text('未解锁 (${locked.length})', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          ...locked.map((a) => _badgeCard(a, false)),
        ],
      ),
    );
  }

  Widget _summaryItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _badgeCard(Achievement a, bool unlocked) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: unlocked ? AppTheme.accentColor.withValues(alpha: 0.15) : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(a.icon, style: TextStyle(fontSize: 22, color: unlocked ? null : AppTheme.textSecondary)),
          ),
        ),
        title: Text(a.title, style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: unlocked ? AppTheme.textPrimary : AppTheme.textSecondary,
        )),
        subtitle: Text(a.description, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        trailing: unlocked
            ? Icon(Icons.check_circle, color: AppTheme.success, size: 22)
            : Icon(Icons.lock_outline, color: AppTheme.textSecondary.withValues(alpha: 0.4), size: 20),
      ),
    );
  }
}