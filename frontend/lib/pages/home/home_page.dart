import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../models/statistics.dart';
import '../../widgets/study_timer_card.dart';
import '../interview/mock_interview_page.dart';
import '../ai_chat/quiz_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().loadTodayTasks();
      final stats = context.read<StatisticsProvider>();
      stats.loadDailyStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MindFlow')),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<ReviewProvider>().loadTodayTasks();
          await context.read<StatisticsProvider>().loadDailyStats();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatsCard(),
            SizedBox(height: 16),
            _buildTimerCard(),
            const SizedBox(height: 16),
            _buildMockInterviewEntry(),
            const SizedBox(height: 16),
            _buildQuizEntry(),
            const SizedBox(height: 16),
            _buildTodayTasks(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Consumer<StatisticsProvider>(
      builder: (context, stats, _) {
        final d = stats.dailyStats ?? DailyStats(date: DateTime.now().toIso8601String().substring(0, 10));

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('今日学习', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const Spacer(),
                    if (d.streak > 0) ...[
                      Icon(Icons.local_fire_department, color: AppTheme.warning, size: 20),
                      SizedBox(width: 4),
                      Text('${d.streak} 天', style: TextStyle(color: AppTheme.warning, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem(Icons.note_add_outlined, '${d.noteCount}', '笔记'),
                    _statItem(Icons.replay_outlined, '${d.reviewCount}', '复习'),
                    _statItem(Icons.quiz_outlined, '${d.interviewCount}', '面试题'),
                  ],
                ),
                if (stats.error != null) ...[
                  const SizedBox(height: 8),
                  Text(stats.error!, style: TextStyle(color: AppTheme.error, fontSize: 12)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerCard() {
    return Consumer2<StatisticsProvider, AuthProvider>(
      builder: (context, stats, auth, _) {
        final duration = stats.dailyStats?.studyDuration ?? 0;
        final streak = stats.dailyStats?.streak ?? 0;
        final goal = int.tryParse(auth.user?.studyTarget ?? '') ?? 120;
        return StudyTimerCard(
          initialSeconds: duration,
          streak: streak,
          dailyGoalMinutes: goal,
          onReportDuration: (seconds) => stats.reportDuration(seconds),
        );
      },
    );
  }

  Widget _buildMockInterviewEntry() {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MockInterviewPage())),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.school_outlined, color: AppTheme.accentColor),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI 模拟面试', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    SizedBox(height: 2),
                    Text('AI 扮演面试官，模拟真实面试场景', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizEntry() {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizPage())),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.quiz_outlined, color: AppTheme.success),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI 知识测验', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    SizedBox(height: 2),
                    Text('基于笔记生成测验题，检验学习效果', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accentColor, size: 28),
        SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildTodayTasks() {
    return Consumer<ReviewProvider>(
      builder: (context, review, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('今日复习任务', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            SizedBox(height: 12),
            if (review.isLoading)
              Center(child: CircularProgressIndicator())
            else if (review.error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    Text(review.error!, style: TextStyle(color: AppTheme.error, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextButton(onPressed: () => review.loadTodayTasks(), child: const Text('重试')),
                  ]),
                ),
              )
            else if (review.todayTasks.isEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('今天没有复习任务，去学习新知识吧', style: TextStyle(color: AppTheme.textSecondary))),
                ),
              )
            else
              ...review.todayTasks.map((task) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task.noteSummary ?? '复习内容', maxLines: 2, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                                if (task.category != null) ...[
                                  SizedBox(height: 4),
                                  Text(task.category!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                ],
                                SizedBox(height: 4),
                                Text('记忆分数: ${task.memoryScore ?? 100}', style: TextStyle(color: AppTheme.warning, fontSize: 12)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _showScoreDialog(task.planId),
                            child: const Text('完成复习'),
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        );
      },
    );
  }

  void _showScoreDialog(int planId) {
    int score = 80;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('记忆评分'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('你觉得自己记住了多少？'),
              const SizedBox(height: 16),
              Slider(
                value: score.toDouble(),
                min: 0,
                max: 100,
                divisions: 10,
                label: '$score',
                onChanged: (v) => setDialogState(() => score = v.round()),
              ),
              Text('$score 分', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            ElevatedButton(
              onPressed: () async {
                await context.read<ReviewProvider>().completeReview(planId, score);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('确认'),
            ),
          ],
        ),
      ),
    );
  }
}